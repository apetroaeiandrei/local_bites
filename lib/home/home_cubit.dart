import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/notifications_repo.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/delivery_address.dart';
import 'package:models/restaurant_model.dart';
import 'package:models/user_order.dart';

import '../analytics/metric.dart';
import '../routes.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._userRepo,
    this._restaurantsRepo,
    this._ordersRepo,
    this._cartRepo,
    this._notificationsRepo,
    this._analytics,
  ) : super(const HomeState(
            status: HomeStatus.initial,
            restaurants: [],
            currentOrders: [],
            showCurrentOrder: false,
            showNotificationsPrompt: false)) {
    init();
  }

  static const _showAlertMaxDistance = 100;
  final UserRepo _userRepo;
  final RestaurantsRepo _restaurantsRepo;
  final OrdersRepo _ordersRepo;
  final CartRepo _cartRepo;
  final NotificationsRepo _notificationsRepo;
  final Analytics _analytics;
  StreamSubscription? _currentOrderSubscription;
  StreamSubscription? _restaurantsSubscription;
  DateTime? _lastLocationCheckTime;

  init() async {
    _analytics.setCurrentScreen(screenName: Routes.home);
    if (!await _userRepo.isProfileCompleted()) {
      _analytics.setCurrentScreen(screenName: Routes.profile);
      emit(state.copyWith(status: HomeStatus.profileIncomplete));
      return;
    }

    final address = _userRepo.address;
    if (address == null) {
      _analytics.setCurrentScreen(screenName: Routes.addresses);
      emit(state.copyWith(status: HomeStatus.addressError));
      return;
    }

    try {
      _restaurantsSubscription =
          _restaurantsRepo.restaurantsStream.listen((restaurants) {
        _handleRestaurantsLoaded(address);
      });
      _restaurantsRepo.listenForNearbyRestaurants(
          address.latitude, address.longitude);
    } catch (e) {
      _analytics.logEvent(name: Metric.eventRestaurantsError);
      emit(state.copyWith(
        status: HomeStatus.restaurantsError,
      ));
    }

    _currentOrderSubscription = _ordersRepo.currentOrderStream.listen((orders) {
      _analytics.logEventWithParams(name: Metric.eventOrderUpdate, parameters: {
        Metric.propertyOrderStatus: orders.map((e) => e.status).join(','),
        Metric.propertyOrderCount: orders.length,
      });

      emit(state.copyWith(
          currentOrders: orders, showCurrentOrder: orders.isNotEmpty));
    });
    _ordersRepo.listenForOrderInProgress();
  }

  void _handleRestaurantsLoaded(DeliveryAddress address) {
    List<RestaurantModel> restaurants =
        _restaurantsRepo.restaurants.where((element) => element.open).toList();
    restaurants.sort((a, b) => b.maxPromo.compareTo(a.maxPromo));
    restaurants
        .addAll(_restaurantsRepo.restaurants.where((element) => !element.open));

    _analytics.logEventWithParams(
      name: Metric.eventRestaurantsLoaded,
      parameters: {
        Metric.propertyRestaurantsCount: restaurants.length,
      },
    );

    emit(state.copyWith(
      status: HomeStatus.loaded,
      restaurants: restaurants,
      address: address,
    ));
    _checkNotificationsPermissions();

    _userRepo.addressesStream.listen((address) {
      _checkDistance();
    });
    _userRepo.listenForAddresses();
  }

  @override
  Future<void> close() {
    _currentOrderSubscription?.cancel();
    _restaurantsSubscription?.cancel();
    _ordersRepo.stopListeningForOrderInProgress();
    _restaurantsRepo.cancelAllRestaurantsSubscriptions();
    return super.close();
  }

  void rateOrder(UserOrder currentOrder, bool? liked) {
    _analytics.logEventWithParams(name: Metric.eventOrderRate, parameters: {
      Metric.propertyOrderLiked:
          liked?.toString() ?? Metric.propertyValueOrderClosed,
    });
    _ordersRepo.rateOrder(currentOrder, liked);
  }

  bool hasCartOnDifferentRestaurant(String restaurantId) {
    if (_cartRepo.selectedRestaurantId == null ||
        _cartRepo.selectedRestaurantId == restaurantId) {
      return false;
    } else {
      if (_cartRepo.cartCount > 0) {
        _analytics.logEvent(name: Metric.eventProductsInCartDialog);
        return true;
      } else {
        return false;
      }
    }
  }

  void setRestaurantId(String restaurantId) {
    _cartRepo.selectedRestaurantId = restaurantId;
  }

  void onAppLifecycleStateChanged(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _restaurantsSubscription?.cancel();
      _restaurantsSubscription = null;
      _restaurantsRepo.cancelAllRestaurantsSubscriptions();
    }

    if (state == AppLifecycleState.resumed &&
        _restaurantsSubscription == null) {
      init();
    }
  }

  //region Notifications
  Future<void> _checkNotificationsPermissions() async {
    final permissionGranted =
        await _notificationsRepo.areNotificationsEnabled();
    if (permissionGranted) {
      onWantNotificationsClick();
    }
    emit(state.copyWith(showNotificationsPrompt: !permissionGranted));
  }

  void onWantNotificationsClick() async {
    final notificationsAllowed =
        await _notificationsRepo.registerNotifications();
    if (notificationsAllowed) {
      _analytics.logEvent(name: Metric.eventFCMPermissionGranted);
      emit(state.copyWith(showNotificationsPrompt: false));
    } else {
      _analytics.logEvent(name: Metric.eventFCMPermissionDenied);
      final currentStatus = state.status;
      emit(state.copyWith(status: HomeStatus.showSettingsNotification));
      Future.delayed(const Duration(milliseconds: 20), () {
        emit(state.copyWith(status: currentStatus));
      });
      return;
    }
  }

//endregion

  Future<void> _checkDistance() async {
    if (_lastLocationCheckTime != null &&
        DateTime.now().difference(_lastLocationCheckTime!).inMinutes < 10) {
      return;
    }

    _lastLocationCheckTime = DateTime.now();

    try {
      final position = await Geolocator.getCurrentPosition();
      if (isClosed) return;
      GeoFirePoint center = GeoFlutterFire()
          .point(latitude: position.latitude, longitude: position.longitude);
      final distanceMeters = center.distance(
              lat: _userRepo.address!.latitude,
              lng: _userRepo.address!.longitude) *
          1000;
      final accuracyMeters = position.accuracy;

      if (distanceMeters > _showAlertMaxDistance + accuracyMeters) {
        DeliveryAddress? nearestAddress =
            _findNearestAddress(center, accuracyMeters);
        final previousStatus = state.status;
        if (nearestAddress != null) {
          emit(state.copyWith(
              status: HomeStatus.showKnownNearestAddressDialog,
              nearestDeliveryAddress: nearestAddress));
        } else {
          emit(state.copyWith(
              status: HomeStatus.showUnknownNearestAddressDialog));
        }
        Future.delayed(const Duration(milliseconds: 20), () {
          emit(state.copyWith(status: previousStatus));
        });
      }
    } catch (e) {
      if (_userRepo.addresses.length > 1) {
        final previousStatus = state.status;
        emit(state.copyWith(status: HomeStatus.showLocationPermissionDialog));
        Future.delayed(const Duration(milliseconds: 20), () {
          emit(state.copyWith(status: previousStatus));
        });
      }
      _analytics.logEvent(name: Metric.eventHomeAddressLocationError);
    }
  }

  DeliveryAddress? _findNearestAddress(
      GeoFirePoint userLocation, double accuracy) {
    final addresses = _userRepo.addresses;
    if (addresses.isEmpty) {
      return null;
    }

    final distances = addresses.map((e) {
      return userLocation.distance(lat: e.latitude, lng: e.longitude);
    }).toList();

    final minDistance = distances.reduce(min);
    final index = distances.indexOf(minDistance);
    if (minDistance * 1000 > _showAlertMaxDistance + accuracy) {
      return null;
    }
    return addresses[index];
  }

  Future<void> setDeliveryAddress(deliveryAddress) async {
    await _userRepo.setDeliveryAddress(deliveryAddress);
    init();
  }
}

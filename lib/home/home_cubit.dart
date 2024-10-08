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
import 'package:local/repos/vouchers_repo.dart';
import 'package:models/delivery_address.dart';
import 'package:models/restaurant_model.dart';
import 'package:models/user_order.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/metric.dart';
import '../constants.dart';
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
    this._vouchersRepo,
  ) : super(HomeState(
          status: HomeStatus.loading,
          restaurants: const [],
          currentOrders: const [],
          showCurrentOrder: false,
          isNoGoZone: _userRepo.isInNoGoZone,
          showNotificationsPrompt: false,
        )) {
    init();
  }

  static const _showAlertMaxDistance = 100;
  static const _prefsNotificationsPromptDate = 'notificationsPromptDateDelay';
  final UserRepo _userRepo;
  final RestaurantsRepo _restaurantsRepo;
  final OrdersRepo _ordersRepo;
  final CartRepo _cartRepo;
  final NotificationsRepo _notificationsRepo;
  final VouchersRepo _vouchersRepo;
  final Analytics _analytics;
  StreamSubscription? _currentOrderSubscription;
  StreamSubscription? _restaurantsSubscription;
  StreamSubscription? _locationSubscription;
  StreamSubscription? _isInNoGoZoneSubscription;
  DateTime? _lastLocationCheckTime;
  String? _userZipCode;

  init() async {
    _analytics.setCurrentScreen(screenName: Routes.home);
    await _listenForNoGoZones();
    await _userRepo.getUser();
    if (!_userRepo.isProfileCompleted()) {
      _analytics.setCurrentScreen(screenName: Routes.profile);
      emit(state.copyWith(status: HomeStatus.profileIncomplete));
      return;
    }

    _userZipCode = _userRepo.user?.zipCode;
    final address = _userRepo.address;
    if (address == null) {
      _analytics.setCurrentScreen(screenName: Routes.addresses);
      emit(state.copyWith(status: HomeStatus.addressError));
      return;
    }
    await _vouchersRepo.getVouchersConfig();
    await _vouchersRepo.listenForVouchers();

    try {
      await _restaurantsSubscription?.cancel();
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

    await _currentOrderSubscription?.cancel();
    _currentOrderSubscription = _ordersRepo.currentOrderStream.listen((orders) {
      if (orders.isNotEmpty) {
        _analytics
            .logEventWithParams(name: Metric.eventOrderUpdate, parameters: {
          Metric.propertyOrderStatus: orders.map((e) => e.status).join(','),
          Metric.propertyOrderCount: orders.length,
        });
      }
      emit(state.copyWith(
          currentOrders: orders, showCurrentOrder: orders.isNotEmpty));
    });

    _ordersRepo.listenForOrderInProgress();
  }

  List<RestaurantModel> _sortRestaurants(List<RestaurantModel> allRestaurants) {
    final List<RestaurantModel> result = [];
    final groceries =
        allRestaurants.where((element) => element.isGrocery).toList();
    final openGroceries = groceries.where((element) => element.open).toList();
    openGroceries
        .sort((a, b) => b.feedbackPositive.compareTo(a.feedbackPositive));
    final closedGroceries =
        groceries.where((element) => !element.open).toList();

    final restaurants =
        allRestaurants.where((element) => !element.isGrocery).toList();
    List<RestaurantModel> openRestaurants =
        restaurants.where((element) => element.open).toList();
    openRestaurants
        .sort((a, b) => b.feedbackPositive.compareTo(a.feedbackPositive));
    openRestaurants.sort((a, b) => b.maxPromo.compareTo(a.maxPromo));
    final closedRestaurants =
        restaurants.where((element) => !element.open).toList();

    result.addAll(openRestaurants);
    result.addAll(closedRestaurants);
    result.addAll(openGroceries);
    result.addAll(closedGroceries);
    return result;
  }

  Future<void> _handleRestaurantsLoaded(DeliveryAddress address) async {
    final List<RestaurantModel> result =
        _sortRestaurants(_restaurantsRepo.restaurants);

    if (result.isNotEmpty && _userZipCode != result[0].zipCode) {
      _analytics.logEvent(name: Metric.eventUserZipCodeChanged);
      _userZipCode = result[0].zipCode;
      await _userRepo.setUserZipCode(_userZipCode!);
    }
    _analytics.logEventWithParams(
      name: Metric.eventRestaurantsLoaded,
      parameters: {
        Metric.propertyRestaurantsCount: result.length,
      },
    );

    emit(state.copyWith(
      status: HomeStatus.loaded,
      restaurants: result,
      address: address,
    ));
    _checkNotificationsPermissions();

    _locationSubscription = _userRepo.addressesStream.listen((address) {
      _checkDistance();
    });
    _userRepo.listenForAddresses();
  }

  @override
  Future<void> close() {
    _currentOrderSubscription?.cancel();
    _restaurantsSubscription?.cancel();
    _locationSubscription?.cancel();
    _isInNoGoZoneSubscription?.cancel();
    _ordersRepo.stopListeningForOrderInProgress();
    _restaurantsRepo.cancelAllRestaurantsSubscriptions();
    return super.close();
  }

  void rateOrder(UserOrder currentOrder) {
    _ordersRepo.markOrderSettled(currentOrder);
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
    bool showNotificationsPrompt = false;
    if (permissionGranted) {
      onWantNotificationsClick();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final lastPromptDate = prefs.getInt(_prefsNotificationsPromptDate);
      if (lastPromptDate == null) {
        showNotificationsPrompt = true;
      } else {
        final lastPrompt = DateTime.fromMillisecondsSinceEpoch(lastPromptDate);
        showNotificationsPrompt =
            DateTime.now().difference(lastPrompt).inDays > 5;
      }
    }
    emit(state.copyWith(showNotificationsPrompt: showNotificationsPrompt));
  }

  void onWantNotificationsClick() async {
    final zipCode = _userRepo.user?.zipCode ?? Constants.unknownZipCode;
    final notificationsAllowed =
        await _notificationsRepo.registerNotifications(zipCode);
    if (notificationsAllowed) {
      _notificationsRepo.updateFcmToken();
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

  Future<void> onNotificationsLaterClick() async {
    _analytics.logEvent(name: Metric.eventFCMPermissionNotNow);
    emit(state.copyWith(showNotificationsPrompt: false));
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        _prefsNotificationsPromptDate, DateTime.now().millisecondsSinceEpoch);
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
        bool permissionGranted = await Permission.location.request().isGranted;
        if (permissionGranted) {
          return;
        }

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

  Future<void> _listenForNoGoZones() async {
    await _isInNoGoZoneSubscription?.cancel();
    _isInNoGoZoneSubscription =
        _userRepo.isInNoGoZoneStream.listen((isInNoGoZone) {
      emit(state.copyWith(isNoGoZone: isInNoGoZone));
    });
  }

  Future<void> setDeliveryAddress(deliveryAddress) async {
    await _userRepo.setDeliveryAddress(deliveryAddress);
    init();
  }

  void cancelOrder(UserOrder order) {
    _ordersRepo.cancelOrder(order);
  }
}

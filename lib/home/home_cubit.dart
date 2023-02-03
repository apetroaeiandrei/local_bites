import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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

  final UserRepo _userRepo;
  final RestaurantsRepo _restaurantsRepo;
  final OrdersRepo _ordersRepo;
  final CartRepo _cartRepo;
  final NotificationsRepo _notificationsRepo;
  final Analytics _analytics;
  StreamSubscription? _currentOrderSubscription;
  StreamSubscription? _restaurantsSubscription;

  init() async {
    _analytics.setCurrentScreen(screenName: Routes.home);
    if (!await _userRepo.isProfileCompleted()) {
      _analytics.setCurrentScreen(screenName: Routes.profile);
      emit(state.copyWith(status: HomeStatus.profileIncomplete));
      return;
    }

    final address = _userRepo.address;
    if (address == null) {
      _analytics.setCurrentScreen(screenName: Routes.address);
      emit(state.copyWith(status: HomeStatus.addressError));
      return;
    }

    try {
      _restaurantsRepo.listenForNearbyRestaurants(
          address.latitude, address.longitude);
      _restaurantsSubscription =
          _restaurantsRepo.restaurantsStream.listen((restaurants) {
        _handleRestaurantsLoaded(address);
      });
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
    _checkNotificationsPermissions();
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
      address: address.street,
    ));
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
}

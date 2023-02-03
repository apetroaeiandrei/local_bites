import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/environment/app_config.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/delivery_address.dart';
import 'package:models/restaurant_model.dart';
import 'package:models/user_order.dart';
import 'package:permission_handler/permission_handler.dart';

import '../analytics/metric.dart';
import '../routes.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._userRepo, this._restaurantsRepo, this._ordersRepo,
      this._cartRepo, this._analytics)
      : super(const HomeState(
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
    var permissionGranted = await Permission.notification.isGranted;
    emit(state.copyWith(showNotificationsPrompt: !permissionGranted));
  }

  void onWantNotificationsClick() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
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

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: false,
      sound: true,
    );

    //todo refactor this
    if (!AppConfig.isProd) {
      String? token = await messaging.getToken();
      String? userID = FirebaseAuth.instance.currentUser?.uid;
      FirebaseFirestore.instance
          .collection('tokens')
          .doc(userID)
          .set({'token': token});
    }
  }
//endregion
}

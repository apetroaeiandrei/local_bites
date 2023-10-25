import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/vouchers_repo.dart';
import 'package:models/delivery_prices.dart';
import 'package:models/payment_type.dart';
import 'package:local/cart/stripe_pay_data.dart';
import 'package:local/constants.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/delivery_zone.dart';
import 'package:models/food_order.dart';
import 'package:models/restaurant_model.dart';
import 'package:models/vouchers/voucher.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(
    this._cartRepo,
    this._restaurantsRepo,
    this._userRepo,
    this._ordersRepo,
    this._vouchersRepo,
  ) : super(CartState(
          status: _restaurantsRepo.selectedRestaurant.hasExternalDelivery &&
                  _restaurantsRepo.selectedRestaurant.couriersAvailable
              ? CartStatus.computingDelivery
              : CartStatus.initial,
          cartCount: _cartRepo.cartCount,
          cartTotalProducts: _cartRepo.cartTotalProducts,
          cartItems: _cartRepo.cartItems,
          mentions: _cartRepo.mentions,
          restaurantName: _restaurantsRepo.selectedRestaurant.name,
          deliveryStreet: _userRepo.address?.street ?? "",
          deliveryPropertyDetails: _userRepo.address?.propertyDetails ?? "",
          deliveryLatitude: _userRepo.address?.latitude ?? 0.0,
          deliveryLongitude: _userRepo.address?.longitude ?? 0.0,
          restaurantLatitude:
              _restaurantsRepo.selectedRestaurant.location.latitude,
          restaurantLongitude:
              _restaurantsRepo.selectedRestaurant.location.longitude,
          restaurantAddress: _restaurantsRepo.selectedRestaurant.address,
          minOrder: _restaurantsRepo.selectedRestaurant.minimumOrder,
          badWeatherTax: _userRepo.deliveryPrices.deliveryBadWeatherEnabled
              ? _userRepo.deliveryPrices.deliveryBadWeatherTax
              : 0,
          deliveryFee: _restaurantsRepo.selectedRestaurant.hasExternalDelivery
              ? Constants.deliveryPriceErrorDefault
              : _restaurantsRepo.selectedRestaurant.deliveryFee,
          deliveryEta: 0,
          amountToMinOrder: 0,
          hasDelivery: _restaurantsRepo.selectedRestaurant.hasDelivery ||
              (_restaurantsRepo.selectedRestaurant.hasExternalDelivery &&
                  _restaurantsRepo.selectedRestaurant.couriersAvailable),
          hasPickup: _restaurantsRepo.selectedRestaurant.hasPickup,
          hasDeliveryCash: _restaurantsRepo.selectedRestaurant.hasDeliveryCash,
          hasDeliveryCard: _restaurantsRepo.selectedRestaurant.hasDeliveryCard,
          hasPickupCash: _restaurantsRepo.selectedRestaurant.hasPickupCash,
          hasPickupCard: _restaurantsRepo.selectedRestaurant.hasPickupCard,
          deliverySelected:
              _getInitialDeliverySelected(_restaurantsRepo.selectedRestaurant),
          hasExternalDelivery:
              _restaurantsRepo.selectedRestaurant.hasExternalDelivery,
          hasPayments: _restaurantsRepo.selectedRestaurant.stripeConfigured,
          clearVoucher: false,
          vouchers: _vouchersRepo.vouchers,
          paymentType: _restaurantsRepo.selectedRestaurant.stripeConfigured
              ? PaymentType.app
              : PaymentType.cash,
          acceptsVouchers: _restaurantsRepo.selectedRestaurant.acceptsVouchers,
        )) {
    init();
  }

  final OrdersRepo _ordersRepo;
  final CartRepo _cartRepo;
  final RestaurantsRepo _restaurantsRepo;
  final UserRepo _userRepo;
  final VouchersRepo _vouchersRepo;

  late final DeliveryZone _deliveryZone;
  late final String _orderId;

  StreamSubscription? _currentOrderSubscription;
  StreamSubscription? _vouchersSubscription;
  int length = -1;

  final _delayedDuration = const Duration(milliseconds: 10);
  bool _userChangedPaymentType = false;

  static bool _getInitialDeliverySelected(RestaurantModel restaurantModel) {
    if (restaurantModel.hasExternalDelivery &&
        restaurantModel.couriersAvailable) {
      return true;
    }
    if (restaurantModel.hasDelivery && !restaurantModel.hasExternalDelivery) {
      return true;
    }
    return false;
  }

  Future<void> init() async {
    _listenForOrders();
    _listenForVouchers();
    _orderId = _generateOrderId();
    await _getDelivery();
    Future.delayed(_delayedDuration, () {
      _refreshCart();
    });
  }

  _listenForVouchers() {
    _vouchersSubscription = _vouchersRepo.vouchersStream.listen((vouchers) {
      emit(state.copyWith(vouchers: vouchers));
    });
  }

  _listenForOrders() async {
    length = _ordersRepo.currentOrders.length;
    await _currentOrderSubscription?.cancel();
    _currentOrderSubscription = _ordersRepo.currentOrderStream.listen((orders) {
      if (orders.length > length) {
        // New order
        _cartRepo.clearCart();
        emit(state.copyWith(status: CartStatus.orderSuccess));
      }
    });
  }

  Future<void> checkout() async {
    if (!_restaurantsRepo.selectedRestaurant.open) {
      emit(state.copyWith(status: CartStatus.restaurantClosed));
      Future.delayed(_delayedDuration, () {
        emit(state.copyWith(status: CartStatus.initial));
      });
      return;
    }
    if (_restaurantsRepo.selectedRestaurant.hasExternalDelivery &&
        !_restaurantsRepo.selectedRestaurant.couriersAvailable &&
        state.deliverySelected) {
      emit(state.copyWith(
          status: CartStatus.couriersUnavailable,
          hasExternalDelivery: false,
          hasDelivery: false,
          deliverySelected: false));
      Future.delayed(_delayedDuration, () {
        emit(state.copyWith(status: CartStatus.initial));
      });
      return;
    }
    if (state.paymentType == PaymentType.app) {
      _initStripePayment();
    } else {
      _placeOrder();
    }
  }

  Future<void> _placeOrder() async {
    emit(state.copyWith(status: CartStatus.orderPending));
    num deliveryFee = state.deliverySelected ? state.deliveryFee : 0;
    if (state.hasExternalDelivery &&
        state.deliverySelected &&
        _userRepo.deliveryPrices.deliveryBadWeatherEnabled) {
      deliveryFee += _userRepo.deliveryPrices.deliveryBadWeatherTax;
    }
    final success = await _cartRepo.placeOrder(
      mentions: state.mentions,
      isDelivery: state.deliverySelected && state.hasDelivery,
      deliveryFee: deliveryFee,
      deliveryEta: state.deliveryEta.toInt(),
      paymentType: state.paymentType,
      isExternalDelivery: state.hasExternalDelivery,
      orderId: _orderId,
      voucherId: state.selectedVoucher?.id ?? "",
      voucherValue: state.selectedVoucher?.value ?? 0.0,
    );
    if (!success) {
      emit(state.copyWith(status: CartStatus.orderError));
    }
  }

  void updateMentions(String? mentions) {
    _cartRepo.updateMentions(mentions ?? "");
    emit(state.copyWith(mentions: mentions));
  }

  void add(FoodOrder item) {
    _cartRepo.increaseItemQuantity(item);
    _refreshCart();
  }

  void remove(FoodOrder item) {
    _cartRepo.decreaseItemQuantity(item);
    if (!_isVoucherApplicable()) {
      emit(state.copyWith(clearVoucher: true));
    }
    Future.delayed(_delayedDuration, () {
      _refreshCart();
    });
  }

  void _refreshCart() {
    num amountToMinOrder = 0;
    num deliveryFee = state.deliveryFee;
    CartStatus status = state.status;
    if (!_restaurantsRepo.selectedRestaurant.hasExternalDelivery &&
        state.deliverySelected) {
      final voucherValue = state.selectedVoucher?.value ?? 0;
      amountToMinOrder =
          state.minOrder - (_cartRepo.cartTotalProducts - voucherValue);
      amountToMinOrder = double.parse(amountToMinOrder.toStringAsFixed(2));
      amountToMinOrder = amountToMinOrder > 0 ? amountToMinOrder : 0;
      deliveryFee = amountToMinOrder <= 0 ? 0 : _deliveryZone.deliveryFee;
      status = _isNotMinimumOrder()
          ? CartStatus.minimumOrderError
          : CartStatus.initial;
    }
    emit(state.copyWith(
        cartCount: _cartRepo.cartCount,
        cartTotalProducts: _cartRepo.cartTotalProducts,
        cartItems: _cartRepo.cartItems,
        deliveryFee: deliveryFee,
        amountToMinOrder: amountToMinOrder,
        status: status,
        clearVoucher: false,
        paymentType:
            _userChangedPaymentType ? null : _getDefaultPaymentType()));
  }

  PaymentType _getDefaultPaymentType() {
    if (_restaurantsRepo.selectedRestaurant.stripeConfigured) {
      return PaymentType.app;
    } else if (_restaurantsRepo.selectedRestaurant.hasDeliveryCash) {
      return PaymentType.cash;
    } else if (_restaurantsRepo.selectedRestaurant.hasDeliveryCard) {
      return PaymentType.card;
    } else if (_restaurantsRepo.selectedRestaurant.hasPickupCash) {
      return PaymentType.cash;
    } else if (_restaurantsRepo.selectedRestaurant.hasPickupCard) {
      return PaymentType.card;
    } else {
      return PaymentType.cash;
    }
  }

  void onPaymentTypeChanged(PaymentType paymentType) {
    _userChangedPaymentType = true;
    emit(state.copyWith(paymentType: paymentType));
  }

  void onPaymentFailed() {
    emit(state.copyWith(status: CartStatus.initial, clearPayData: true));
  }

  bool _isNotMinimumOrder() {
    return _cartRepo.cartTotalProducts < _deliveryZone.minimumOrder &&
            _deliveryZone.deliveryFee == 0 ||
        _cartRepo.cartTotalProducts == 0;
  }

  _getDelivery() async {
    if (_restaurantsRepo.selectedRestaurant.hasExternalDelivery) {
      final LatLng restaurantLocation = LatLng(
          _restaurantsRepo.selectedRestaurant.location.latitude,
          _restaurantsRepo.selectedRestaurant.location.longitude);
      final LatLng userLocation =
          LatLng(state.deliveryLatitude, state.deliveryLongitude);
      _getExternalDeliveryPrice(restaurantLocation, userLocation);
    } else {
      await _getDeliveryZones();
    }
  }

  _getDeliveryZones() async {
    final restaurant = _restaurantsRepo.selectedRestaurant;
    final List<DeliveryZone> deliveryZones =
        await _restaurantsRepo.getDeliveryZonesSorted();
    final distance = restaurant.location.distance(
      lat: _userRepo.address!.latitude,
      lng: _userRepo.address!.longitude,
    );
    _deliveryZone = deliveryZones.firstWhere(
      (element) => distance <= element.radius,
      orElse: () => DeliveryZone(
        uid: "",
        radius: 0,
        minimumOrder: restaurant.minimumOrder,
        deliveryFee: restaurant.deliveryFee,
      ),
    );
    emit(state.copyWith(
      minOrder: _deliveryZone.minimumOrder,
      deliveryFee: _deliveryZone.deliveryFee,
    ));
  }

  void _getExternalDeliveryPrice(
      LatLng restaurantLocation, LatLng userLocation) {
    DirectionsService.init(Constants.directionsApiKey);

    final directionsService = DirectionsService();

    final request = DirectionsRequest(
      origin: GeoCoord(
        restaurantLocation.latitude,
        restaurantLocation.longitude,
      ),
      destination: GeoCoord(
        userLocation.latitude,
        userLocation.longitude,
      ),
      travelMode: TravelMode.driving,
    );

    directionsService.route(request,
        (DirectionsResult response, DirectionsStatus? status) {
      if (status == DirectionsStatus.ok) {
        num distance = 0;
        num etaSeconds = 0;
        for (var element in response.routes!.first.legs!) {
          distance += element.distance!.value!;
          etaSeconds += element.duration!.value!;
        }
        double deliveryFee = _computeDeliveryPrice(distance.toInt());
        int etaMinutes = (etaSeconds / 60).ceil();
        emit(state.copyWith(
          deliveryFee: deliveryFee,
          deliveryEta: etaMinutes,
          status: CartStatus.initial,
        ));
      } else {
        emit(state.copyWith(
          deliveryFee: Constants.deliveryPriceErrorDefault,
          deliveryEta: Constants.deliveryEtaErrorDefault,
          status: CartStatus.initial,
        ));
      }
    });
  }

  double _computeDeliveryPrice(int routeDistanceMeters) {
    int adjustedKm = (routeDistanceMeters / 1000).ceil();
    final DeliveryPrices deliveryPrices = _userRepo.deliveryPrices;
    if (adjustedKm > Constants.deliveryMaxPriceKm) {
      return deliveryPrices.deliveryMaximalPrice;
    }

    final price = deliveryPrices.deliveryStartPrice +
        (adjustedKm * deliveryPrices.deliveryPricePerKm);
    if (price < _restaurantsRepo.selectedRestaurant.minExternalDelivery) {
      return _restaurantsRepo.selectedRestaurant.minExternalDelivery;
    }
    return price;
  }

  void toggleDeliverySelected() {
    emit(state.copyWith(deliverySelected: !state.deliverySelected));
  }

  void _initStripePayment() {
    num deliveryFee = state.deliverySelected ? state.deliveryFee : 0;
    if (state.hasExternalDelivery &&
        state.deliverySelected &&
        _userRepo.deliveryPrices.deliveryBadWeatherEnabled) {
      deliveryFee += _userRepo.deliveryPrices.deliveryBadWeatherTax;
    }
    emit(state.copyWith(status: CartStatus.stripeLoading));
    _cartRepo.initStripeCheckout(
      mentions: state.mentions,
      isDelivery: state.deliverySelected && state.hasDelivery,
      deliveryFee: deliveryFee,
      isExternalDelivery: state.hasExternalDelivery,
      deliveryEta: state.deliveryEta.toInt(),
      paymentType: state.paymentType,
      orderId: _orderId,
      user: _userRepo.user!,
      restaurantStripeAccountId:
          _restaurantsRepo.selectedRestaurant.stripeAccountId,
      applicationFee:
          state.hasExternalDelivery && state.deliverySelected ? deliveryFee : 0,
      voucherDiscount:
          state.selectedVoucher != null ? state.selectedVoucher!.value : 0,
      voucherId: state.selectedVoucher?.id ?? "",
      callback: (stripeData) {
        emit(state.copyWith(
          status: CartStatus.stripeReady,
          stripePayData: stripeData,
        ));
      },
    );
  }

  void onPaymentPending() {
    emit(state.copyWith(
      status: CartStatus.orderPending,
    ));
  }

  String _generateOrderId() {
    // return a random string of 5 characters
    final random = Random();
    const chars = 'abcdefghjklmnpqrstuvwxyz23456789';
    return List.generate(5, (index) => chars[random.nextInt(chars.length)])
        .join()
        .toUpperCase();
  }

  @override
  Future<void> close() {
    _currentOrderSubscription?.cancel();
    _vouchersSubscription?.cancel();
    return super.close();
  }

  //region Vouchers
  void onVoucherSelected(Voucher voucher) {
    if (_isVoucherApplicable()) {
      emit(state.copyWith(selectedVoucher: voucher));
      _refreshCart();
    }
  }

  bool _isVoucherApplicable() {
    if (state.selectedVoucher == null) {
      return true;
    }
    if (state.selectedVoucher!.minPurchase > _cartRepo.cartTotalProducts) {
      return false;
    }
    return true;
  }
//endregion
}

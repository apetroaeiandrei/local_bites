import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/constants.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/delivery_zone.dart';
import 'package:models/food_order.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit(this._cartRepo, this._restaurantsRepo, this._userRepo)
      : super(CartState(
            status: CartStatus.initial,
            cartCount: _cartRepo.cartCount,
            cartTotal: _cartRepo.cartTotal,
            cartItems: _cartRepo.cartItems,
            mentions: "",
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
            deliveryFee: _restaurantsRepo.selectedRestaurant.deliveryFee,
            deliveryEta: 0,
            amountToMinOrder: 0,
            hasDelivery: _restaurantsRepo.selectedRestaurant.hasDelivery ||
                _restaurantsRepo.selectedRestaurant.hasExternalDelivery,
            hasPickup: _restaurantsRepo.selectedRestaurant.hasPickup,
            hasDeliveryCash:
                _restaurantsRepo.selectedRestaurant.hasDeliveryCash,
            hasDeliveryCard:
                _restaurantsRepo.selectedRestaurant.hasDeliveryCard,
            hasPickupCash: _restaurantsRepo.selectedRestaurant.hasPickupCash,
            hasPickupCard: _restaurantsRepo.selectedRestaurant.hasPickupCard)) {
    init();
  }

  final CartRepo _cartRepo;
  final RestaurantsRepo _restaurantsRepo;
  late final DeliveryZone _deliveryZone;

  // ignore: unused_field
  final UserRepo _userRepo;
  final _delayedDuration = const Duration(milliseconds: 10);

  Future<void> init() async {
    _getDelivery();
    Future.delayed(_delayedDuration, () {
      _refreshCart();
    });
  }

  Future<void> checkout(bool deliverySelected) async {
    if (!_restaurantsRepo.selectedRestaurant.open) {
      emit(state.copyWith(status: CartStatus.restaurantClosed));
      Future.delayed(_delayedDuration, () {
        emit(state.copyWith(status: CartStatus.initial));
      });
      return;
    }
    final success = await _cartRepo.placeOrder(
      state.mentions,
      deliverySelected && state.hasDelivery,
      state.deliveryFee,
      state.deliveryEta.toInt(),
    );
    if (success) {
      emit(state.copyWith(status: CartStatus.orderSuccess));
    } else {
      emit(state.copyWith(status: CartStatus.orderError));
    }
  }

  void updateMentions(String? mentions) {
    emit(state.copyWith(mentions: mentions));
  }

  void add(FoodOrder item) {
    _cartRepo.increaseItemQuantity(item);
    _refreshCart();
  }

  void remove(FoodOrder item) {
    _cartRepo.decreaseItemQuantity(item);
    _refreshCart();
  }

  void _refreshCart() {
    num amountToMinOrder = 0;
    num deliveryFee = state.deliveryFee;
    CartStatus status = CartStatus.initial;
    if (!_restaurantsRepo.selectedRestaurant.hasExternalDelivery) {
      amountToMinOrder = state.minOrder - _cartRepo.cartTotal;
      amountToMinOrder = double.parse(amountToMinOrder.toStringAsFixed(2));
      deliveryFee = amountToMinOrder <= 0 ? 0 : _deliveryZone.deliveryFee;
      status = _isNotMinimumOrder()
          ? CartStatus.minimumOrderError
          : CartStatus.initial;
    }
    emit(state.copyWith(
        cartCount: _cartRepo.cartCount,
        cartTotal: _cartRepo.cartTotal,
        cartItems: _cartRepo.cartItems,
        deliveryFee: deliveryFee,
        amountToMinOrder: amountToMinOrder > 0 ? amountToMinOrder : 0,
        status: status));
  }

  bool _isNotMinimumOrder() {
    return _cartRepo.cartTotal < _deliveryZone.minimumOrder &&
            _deliveryZone.deliveryFee == 0 ||
        _cartRepo.cartTotal == 0;
  }

  _getDelivery() {
    if (_restaurantsRepo.selectedRestaurant.hasExternalDelivery) {
      final LatLng restaurantLocation = LatLng(
          _restaurantsRepo.selectedRestaurant.location.latitude,
          _restaurantsRepo.selectedRestaurant.location.longitude);
      final LatLng userLocation =
          LatLng(state.deliveryLatitude, state.deliveryLongitude);
      _getExternalDeliveryPrice(restaurantLocation, userLocation);
    } else {
      _getDeliveryZones();
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
        int deliveryFee = _computeDeliveryPrice(distance.toInt());
        int etaMinutes = (etaSeconds / 60).ceil();
        emit(state.copyWith(deliveryFee: deliveryFee, deliveryEta: etaMinutes));
      } else {
        emit(state.copyWith(
          deliveryFee: Constants.deliveryPriceErrorDefault,
          deliveryEta: Constants.deliveryEtaErrorDefault,
        ));
      }
    });
  }

  int _computeDeliveryPrice(int routeDistanceMeters) {
    int adjustedKm = (routeDistanceMeters / 1000).ceil();
    return Constants.deliveryPriceStart +
        (adjustedKm * Constants.deliveryPricePerKm);
  }
}

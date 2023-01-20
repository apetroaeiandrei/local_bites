import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
            amountToMinOrder: 0,
            hasDelivery: _restaurantsRepo.selectedRestaurant.hasDelivery,
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
    await _getDeliveryZones();
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
    final success = await _cartRepo.placeOrder(state.mentions,
        deliverySelected && state.hasDelivery, state.deliveryFee);
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
    num amountToMinOrder = state.minOrder - _cartRepo.cartTotal;
    num deliveryFee = amountToMinOrder <= 0 ? 0 : _deliveryZone.deliveryFee;
    emit(state.copyWith(
        cartCount: _cartRepo.cartCount,
        cartTotal: _cartRepo.cartTotal,
        cartItems: _cartRepo.cartItems,
        deliveryFee: deliveryFee,
        amountToMinOrder: amountToMinOrder > 0 ? amountToMinOrder : 0,
        status: _isNotMinimumOrder()
            ? CartStatus.minimumOrderError
            : CartStatus.initial));
  }

  bool _isNotMinimumOrder() {
    return _cartRepo.cartTotal < _deliveryZone.minimumOrder &&
        _deliveryZone.deliveryFee == 0 || _cartRepo.cartTotal == 0;
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
}

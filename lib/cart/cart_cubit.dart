import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
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
            minOrder: _restaurantsRepo.selectedRestaurant.minimumOrder)) {
    init();
  }

  final CartRepo _cartRepo;
  final RestaurantsRepo _restaurantsRepo;
  final UserRepo _userRepo;

  void init() {
    Future.delayed(
        const Duration(
          milliseconds: 10,
        ), () {
      _refreshCart();
    });
  }

  Future<void> checkout() async {
    final success = await _cartRepo.placeOrder(state.mentions);
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
    print("refreshing cart");
    emit(state.copyWith(
        cartCount: _cartRepo.cartCount,
        cartTotal: _cartRepo.cartTotal,
        cartItems: _cartRepo.cartItems,
        status: _isNotMinimumOrder()
            ? CartStatus.minimumOrderError
            : CartStatus.initial));
  }

  bool _isNotMinimumOrder() {
    return _cartRepo.cartTotal <
        _restaurantsRepo.selectedRestaurant.minimumOrder;
  }
}

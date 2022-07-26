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
            deliveryLongitude: _userRepo.address?.longitude ?? 0.0,));

  final CartRepo _cartRepo;
  final RestaurantsRepo _restaurantsRepo;
  final UserRepo _userRepo;

  void checkout() {
    _cartRepo.placeOrder().then((value) {
      if (value) {
        emit(state.copyWith(status: CartStatus.orderSuccess));
      }
    });
  }
}

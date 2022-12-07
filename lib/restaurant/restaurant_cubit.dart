import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:models/food_model.dart';
import 'package:models/restaurant_model.dart';

import 'category_content.dart';

part 'restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  RestaurantCubit(
    this._restaurantsRepo,
    this._cartRepo,
    this._restaurant,
  ) : super(RestaurantState(
          name: _restaurant.name,
          status: RestaurantStatus.initial,
          foods: [],
          categories: [],
          cartCount: _cartRepo.cartCount,
          cartTotal: _cartRepo.cartTotal,
        )) {
    _init();
  }

  final RestaurantsRepo _restaurantsRepo;
  final CartRepo _cartRepo;
  final RestaurantModel _restaurant;

  _init() async {
    _restaurantsRepo.selectedRestaurantId = _restaurant.id;
    _cartRepo.selectedRestaurantId = _restaurant.id;
    await _restaurantsRepo.getCategoriesAsync();
    await _restaurantsRepo.getFoodsAsync();
    _refreshFoodsContent();
  }

  _refreshFoodsContent() {
    final categories = _restaurantsRepo.getCategoriesContent();
    final categoriesContent = categories.map((category) {
      final foods = _restaurantsRepo.getFoodsByCategory(category.id);
      return CategoryContent(
        category: category,
        foods: foods,
      );
    }).toList();
    emit(state.copyWith(
      foods: _restaurantsRepo.getFoodsContent(),
      categories: categoriesContent,
    ));
  }

  void addToCart(FoodModel food) {
    _cartRepo.addToCart(food, 1, {}, food.price);
    refreshCart();
  }

  void refreshCart() {
    print("refreshCart");
    emit(state.copyWith(
      cartCount: _cartRepo.cartCount,
      cartTotal: _cartRepo.cartTotal,
    ));
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/delivery_zone.dart';
import 'package:models/food_model.dart';
import 'package:models/restaurant_model.dart';

import 'category_content.dart';

part 'restaurant_state.dart';

class RestaurantCubit extends Cubit<RestaurantState> {
  RestaurantCubit(
    this._userRepo,
    this._restaurantsRepo,
    this._cartRepo,
    this._restaurant,
  ) : super(RestaurantState(
          name: _restaurant.name,
          status: RestaurantStatus.initial,
          foods: const [],
          categories: const [],
          cartCount: _cartRepo.cartCount,
          cartTotal: _cartRepo.cartTotal,
          deliveryFee: _restaurant.deliveryFee,
          minimumOrder: _restaurant.minimumOrder,
        )) {
    _init();
  }

  final UserRepo _userRepo;
  final RestaurantsRepo _restaurantsRepo;
  final CartRepo _cartRepo;
  final RestaurantModel _restaurant;

  _init() async {
    _restaurantsRepo.selectedRestaurantId = _restaurant.id;
    _cartRepo.selectedRestaurantId = _restaurant.id;
    await _getDeliveryZones();
    await _restaurantsRepo.getFoodsAsync();
    await _restaurantsRepo.getCategoriesAsync();
    _refreshFoodsContent();
  }

  _getDeliveryZones() async {
    final List<DeliveryZone> deliveryZones =
        await _restaurantsRepo.getDeliveryZonesSorted();
    final distance = _restaurant.location.distance(
      lat: _userRepo.address!.latitude,
      lng: _userRepo.address!.longitude,
    );
    final deliveryZone = deliveryZones.firstWhere(
      (element) => distance <= element.radius,
      orElse: () => DeliveryZone(
        uid: "",
        radius: 0,
        minimumOrder: _restaurant.minimumOrder,
        deliveryFee: _restaurant.deliveryFee,
      ),
    );
    if (isClosed) return;
    emit(state.copyWith(
      minimumOrder: deliveryZone.minimumOrder,
      deliveryFee: deliveryZone.deliveryFee,
    ));
  }

  _refreshFoodsContent() {
    if (isClosed) return;
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

  void refreshCart() {
    emit(state.copyWith(
      cartCount: _cartRepo.cartCount,
      cartTotal: _cartRepo.cartTotal,
    ));
  }

  @override
  Future<void> close() async {
    await _restaurantsRepo.cancelSubscriptions();
    return super.close();
  }
}

part of 'restaurant_cubit.dart';

enum RestaurantStatus {
  initial,
  loading,
  loaded,
  error,
}

class RestaurantState extends Equatable {
  final String name;
  final RestaurantStatus status;
  final List<FoodModel> foods;
  final List<CategoryContent> categories;
  final int cartCount;
  final double cartTotal;

  @override
  List<Object> get props =>
      [name, status, foods, categories, cartCount, cartTotal];

  const RestaurantState({
    required this.name,
    required this.status,
    required this.foods,
    required this.categories,
    required this.cartCount,
    required this.cartTotal,
  });

  RestaurantState copyWith({
    String? name,
    RestaurantStatus? status,
    List<FoodModel>? foods,
    List<CategoryContent>? categories,
    int? cartCount,
    double? cartTotal,
  }) {
    return RestaurantState(
      name: name ?? this.name,
      status: status ?? this.status,
      foods: foods ?? this.foods,
      categories: categories ?? this.categories,
      cartCount: cartCount ?? this.cartCount,
      cartTotal: cartTotal ?? this.cartTotal,
    );
  }
}

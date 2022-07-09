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

  @override
  List<Object> get props => [name, status, foods, categories];

  const RestaurantState({
    required this.name,
    required this.status,
    required this.foods,
    required this.categories,
  });

  RestaurantState copyWith({
    String? name,
    RestaurantStatus? status,
    List<FoodModel>? foods,
    List<CategoryContent>? categories,
  }) {
    return RestaurantState(
      name: name ?? this.name,
      status: status ?? this.status,
      foods: foods ?? this.foods,
      categories: categories ?? this.categories,
    );
  }
}

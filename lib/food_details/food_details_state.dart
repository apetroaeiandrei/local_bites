part of 'food_details_cubit.dart';

class FoodDetailsState extends Equatable {
  final FoodModel food;
  final List<FoodOptionCategory> options;
  final Set<String> selectedOptions;
  final double price;
  final int quantity;

  @override
  List<Object> get props =>
      [food, options, price, quantity, selectedOptions, options];

  const FoodDetailsState({
    required this.food,
    required this.options,
    required this.selectedOptions,
    required this.price,
    required this.quantity,
  });

  FoodDetailsState copyWith({
    FoodModel? food,
    List<FoodOptionCategory>? options,
    Set<String>? selectedOptions,
    double? price,
    int? quantity,
  }) {
    return FoodDetailsState(
      food: food ?? this.food,
      options: options ?? this.options,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}

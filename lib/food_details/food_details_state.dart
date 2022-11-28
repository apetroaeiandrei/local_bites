part of 'food_details_cubit.dart';

enum FoodDetailsStatus { initial, loading, addSuccess, optionsError }

class FoodDetailsState extends Equatable {
  final FoodModel food;
  final List<FoodOptionCategory> options;
  final Set<String> selectedOptions;
  final double price;
  final int quantity;
  final Set<FoodOptionCategory> invalidOptions;
  final FoodDetailsStatus status;

  @override
  List<Object> get props => [
        food,
        options,
        price,
        quantity,
        selectedOptions,
        options,
        invalidOptions,
        status
      ];

  const FoodDetailsState({
    required this.food,
    required this.options,
    required this.selectedOptions,
    required this.price,
    required this.quantity,
    required this.invalidOptions,
    required this.status,
  });

  FoodDetailsState copyWith({
    FoodModel? food,
    List<FoodOptionCategory>? options,
    Set<String>? selectedOptions,
    double? price,
    int? quantity,
    Set<FoodOptionCategory>? invalidOptions,
    FoodDetailsStatus? status,
  }) {
    return FoodDetailsState(
      food: food ?? this.food,
      options: options ?? this.options,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      invalidOptions: invalidOptions ?? this.invalidOptions,
      status: status ?? this.status,
    );
  }
}

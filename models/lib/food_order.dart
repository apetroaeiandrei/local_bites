import 'package:models/food_model.dart';
import 'package:collection/collection.dart';

class FoodOrder {
  final String id;
  final FoodModel food;
  final int quantity;
  final Map<String, List<String>> selectedOptions;
  final double price;
  /// BE CAREFUL AT == OPERATOR WITH SELECTED OPTIONS PROPERTY
  /// BE CAREFUL AT PARSE OPTIONS METHOD

//<editor-fold desc="Data Methods">

  const FoodOrder({
    required this.id,
    required this.food,
    required this.quantity,
    required this.selectedOptions,
    required this.price,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          food == other.food &&
          quantity == other.quantity &&
          const DeepCollectionEquality()
              .equals(selectedOptions, other.selectedOptions) &&
          price == other.price);

  @override
  int get hashCode =>
      id.hashCode ^
      food.hashCode ^
      quantity.hashCode ^
      selectedOptions.hashCode ^
      price.hashCode;

  @override
  String toString() {
    return 'FoodOrder{' +
        ' id: $id,' +
        ' food: $food,' +
        ' quantity: $quantity,' +
        ' selectedOptions: $selectedOptions,' +
        ' price: $price,' +
        '}';
  }

  FoodOrder copyWith({
    String? id,
    FoodModel? food,
    int? quantity,
    Map<String, List<String>>? selectedOptions,
    double? price,
  }) {
    return FoodOrder(
      id: id ?? this.id,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food': food.toMap(),
      'quantity': quantity,
      'selectedOptions': selectedOptions,
      'price': price,
    };
  }

  factory FoodOrder.fromMap(Map<String, dynamic> map) {
    return FoodOrder(
      id: map['id'] as String,
      food: FoodModel.fromMap(map['food']),
      quantity: map['quantity'] as int,
      selectedOptions: _parseOptions(map['selectedOptions']),
      price: double.parse(map['price'].toString()),
    );
  }

//</editor-fold>

  static Map<String, List<String>> _parseOptions(Map<String, dynamic> options) {
    Map<String, List<String>> parsedOptions = {};
    options.forEach((key, value) {
      parsedOptions[key] = List<String>.from(value);
    });
    return parsedOptions;
  }
}

class FoodOption {
  final String id;
  final String name;
  final double price;

//<editor-fold desc="Data Methods">

  const FoodOption({
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodOption &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price);

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode;

  @override
  String toString() {
    return 'FoodOption{' +
        ' id: $id,' +
        ' name: $name,' +
        ' price: $price,' +
        '}';
  }

  FoodOption copyWith({
    String? id,
    String? name,
    double? price,
  }) {
    return FoodOption(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }

  factory FoodOption.fromMap(Map<String, dynamic> map) {
    return FoodOption(
      id: map['id'] as String,
      name: map['name'] as String,
      price: double.parse(map['price'].toString()),
    );
  }

//</editor-fold>
}

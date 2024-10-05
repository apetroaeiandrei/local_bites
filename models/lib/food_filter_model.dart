class FoodFilterModel {
  String name;
  bool isActive;

//<editor-fold desc="Data Methods">

  FoodFilterModel({
    required this.name,
    required this.isActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodFilterModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          isActive == other.isActive);

  @override
  int get hashCode => name.hashCode ^ isActive.hashCode;

  @override
  String toString() {
    return 'FoodFilterModel{ name: $name, isActive: $isActive,}';
  }

  FoodFilterModel copyWith({
    String? name,
    bool? isActive,
  }) {
    return FoodFilterModel(
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isActive': isActive,
    };
  }

  factory FoodFilterModel.fromMap(Map<String, dynamic> map) {
    return FoodFilterModel(
      name: map['name'] as String,
      isActive: map['isActive'] as bool,
    );
  }

//</editor-fold>
}
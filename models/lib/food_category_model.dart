class FoodCategoryModel {
  String id;
  String name;

//<editor-fold desc="Data Methods">

  FoodCategoryModel({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name);

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() {
    return 'FoodCategoryModel{' +
        ' id: $id,' +
        ' name: $name' +
        '}';
  }

  FoodCategoryModel copyWith({
    String? id,
    String? name,
  }) {
    return FoodCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory FoodCategoryModel.fromMap(Map<String, dynamic> map) {
    return FoodCategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

//</editor-fold>
}

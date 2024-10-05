import 'food_option.dart';
import 'package:collection/collection.dart';

class FoodOptionCategory {
  final String id;
  final String name;
  final String description;
  final int minSelection;
  final int maxSelection;
  final List<FoodOption> options;

//<editor-fold desc="Data Methods">

  const FoodOptionCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.minSelection,
    required this.maxSelection,
    required this.options,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodOptionCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          minSelection == other.minSelection &&
          maxSelection == other.maxSelection &&
          const DeepCollectionEquality().equals(options, other.options));

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      minSelection.hashCode ^
      maxSelection.hashCode ^
      const DeepCollectionEquality().hash(options);

  @override
  String toString() {
    return 'FoodOptionCategory{' +
        ' id: $id,' +
        ' name: $name,' +
        ' description: $description,' +
        ' minSelection: $minSelection,' +
        ' maxSelection: $maxSelection,' +
        ' options: $options,' +
        '}';
  }

  FoodOptionCategory copyWith({
    String? id,
    String? name,
    String? description,
    int? minSelection,
    int? maxSelection,
    List<FoodOption>? options,
  }) {
    return FoodOptionCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      minSelection: minSelection ?? this.minSelection,
      maxSelection: maxSelection ?? this.maxSelection,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'minSelection': minSelection,
      'maxSelection': maxSelection,
      'options': options,
    };
  }

  factory FoodOptionCategory.fromMap(Map<String, dynamic> map) {
    return FoodOptionCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      minSelection: map['minSelection'] as int,
      maxSelection: map['maxSelection'] as int,
      options: map['options'] != null ? map['options'] as List<FoodOption> : [],
    );
  }

//</editor-fold>
}

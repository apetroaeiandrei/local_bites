class FoodModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discountedPrice;
  final String nameEn;
  final String descriptionEn;
  final String imageUrl;
  final String? imageThumbUrl;
  final String categoryId;
  final List<String> labels;
  final List<String> optionIds;
  final bool hasOptions;
  final bool available;
  final bool hasNutritionalInfo;
  final double? portionSize;
  final double? calories;
  final double? fat;
  final double? saturatedFat;
  final double? carbs;
  final double? sugar;
  final double? protein;
  final double? fiber;
  final double? salt;
  final String? allergens;

//<editor-fold desc="Data Methods">
  const FoodModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.nameEn,
    required this.descriptionEn,
    required this.imageUrl,
    required this.categoryId,
    required this.labels,
    required this.optionIds,
    required this.hasOptions,
    required this.available,
    required this.hasNutritionalInfo,
    this.imageThumbUrl,
    this.portionSize,
    this.calories,
    this.fat,
    this.saturatedFat,
    this.carbs,
    this.sugar,
    this.protein,
    this.fiber,
    this.salt,
    this.allergens,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          price == other.price &&
          discountedPrice == other.discountedPrice &&
          nameEn == other.nameEn &&
          descriptionEn == other.descriptionEn &&
          imageUrl == other.imageUrl &&
          imageThumbUrl == other.imageThumbUrl &&
          categoryId == other.categoryId &&
          labels == other.labels &&
          optionIds == other.optionIds &&
          hasOptions == other.hasOptions &&
          available == other.available &&
          hasNutritionalInfo == other.hasNutritionalInfo &&
          portionSize == other.portionSize &&
          calories == other.calories &&
          fat == other.fat &&
          saturatedFat == other.saturatedFat &&
          carbs == other.carbs &&
          sugar == other.sugar &&
          protein == other.protein &&
          fiber == other.fiber &&
          salt == other.salt &&
          allergens == other.allergens);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      price.hashCode ^
      discountedPrice.hashCode ^
      nameEn.hashCode ^
      descriptionEn.hashCode ^
      imageUrl.hashCode ^
      imageThumbUrl.hashCode ^
      categoryId.hashCode ^
      labels.hashCode ^
      optionIds.hashCode ^
      hasOptions.hashCode ^
      available.hashCode ^
      hasNutritionalInfo.hashCode ^
      portionSize.hashCode ^
      calories.hashCode ^
      fat.hashCode ^
      saturatedFat.hashCode ^
      carbs.hashCode ^
      sugar.hashCode ^
      protein.hashCode ^
      fiber.hashCode ^
      salt.hashCode ^
      allergens.hashCode;

  @override
  String toString() {
    return 'FoodModel{' +
        ' id: $id,' +
        ' name: $name,' +
        ' description: $description,' +
        ' price: $price,' +
        ' discountedPrice: $discountedPrice,' +
        ' nameEn: $nameEn,' +
        ' descriptionEn: $descriptionEn,' +
        ' imageUrl: $imageUrl,' +
        ' imageThumbUrl: $imageThumbUrl,' +
        ' categoryId: $categoryId,' +
        ' labels: $labels,' +
        ' optionIds: $optionIds,' +
        ' hasOptions: $hasOptions,' +
        ' available: $available,' +
        ' hasNutritionalInfo: $hasNutritionalInfo,' +
        ' portionSize: $portionSize,' +
        ' calories: $calories,' +
        ' fat: $fat,' +
        ' saturatedFat: $saturatedFat,' +
        ' carbs: $carbs,' +
        ' sugar: $sugar,' +
        ' protein: $protein,' +
        ' fibre: $fiber,' +
        ' salt: $salt,' +
        ' allergens: $allergens,' +
        '}';
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountedPrice,
    String? nameEn,
    String? descriptionEn,
    String? imageUrl,
    String? imageThumbUrl,
    String? categoryId,
    List<String>? labels,
    List<String>? optionIds,
    bool? hasOptions,
    bool? available,
    bool? hasNutritionalInfo,
    double? portionSize,
    double? calories,
    double? fat,
    double? saturatedFat,
    double? carbs,
    double? sugar,
    double? protein,
    double? fiber,
    double? salt,
    String? allergens,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      nameEn: nameEn ?? this.nameEn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      imageUrl: imageUrl ?? this.imageUrl,
      imageThumbUrl: imageThumbUrl ?? this.imageThumbUrl,
      categoryId: categoryId ?? this.categoryId,
      labels: labels ?? this.labels,
      optionIds: optionIds ?? this.optionIds,
      hasOptions: hasOptions ?? this.hasOptions,
      available: available ?? this.available,
      hasNutritionalInfo: hasNutritionalInfo ?? this.hasNutritionalInfo,
      portionSize: portionSize ?? this.portionSize,
      calories: calories ?? this.calories,
      fat: fat ?? this.fat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      protein: protein ?? this.protein,
      fiber: fiber ?? this.fiber,
      salt: salt ?? this.salt,
      allergens: allergens ?? this.allergens,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountedPrice': discountedPrice,
      'nameEn': nameEn,
      'descriptionEn': descriptionEn,
      'imageUrl': imageUrl,
      'imageThumbUrl': imageThumbUrl,
      'categoryId': categoryId,
      'labels': labels,
      'optionIds': optionIds,
      'hasOptions': hasOptions,
      'available': available,
      'hasNutritionalInfo': hasNutritionalInfo,
      'portionSize': portionSize,
      'calories': calories,
      'fat': fat,
      'saturatedFat': saturatedFat,
      'carbs': carbs,
      'sugar': sugar,
      'protein': protein,
      'fibre': fiber,
      'salt': salt,
      'allergens': allergens,
    };
  }

  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      price: double.parse(map['price'].toString()),
      discountedPrice: double.tryParse(map['discountedPrice'].toString()) ?? 0,
      nameEn: map['nameEn'] as String,
      descriptionEn: map['descriptionEn'] as String,
      imageUrl: map['imageUrl'] as String,
      imageThumbUrl: map['imageThumbUrl'] as String?,
      categoryId: map['categoryId'] as String,
      labels: List.from(map['labels']),
      optionIds: List.from(map['optionIds'] ?? []),
      hasOptions: map['hasOptions'] as bool,
      available: map['available'] ?? true,
      hasNutritionalInfo: map['hasNutritionalInfo'] ?? false,
      portionSize: double.tryParse(map['portionSize'].toString()),
      calories: double.tryParse(map['calories'].toString()),
      fat: double.tryParse(map['fat'].toString()),
      saturatedFat: double.tryParse(map['saturatedFat'].toString()),
      carbs: double.tryParse(map['carbs'].toString()),
      sugar: double.tryParse(map['sugar'].toString()),
      protein: double.tryParse(map['protein'].toString()),
      fiber: double.tryParse(map['fibre'].toString()),
      salt: double.tryParse(map['salt'].toString()),
      allergens: map['allergens'] as String?,
    );
  }

//</editor-fold>
}

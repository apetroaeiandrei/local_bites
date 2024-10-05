class DeliveryPrices {
  final double deliveryStartPrice;
  final double deliveryPricePerKm;
  final double deliveryBadWeatherTax;
  final double deliveryMaximalPrice;
  final bool deliveryBadWeatherEnabled;
  final double groceryMaxWeight;
  final double groceryAdditionalPrice;

//<editor-fold desc="Data Methods">
  const DeliveryPrices({
    required this.deliveryStartPrice,
    required this.deliveryPricePerKm,
    required this.deliveryBadWeatherTax,
    required this.deliveryMaximalPrice,
    required this.deliveryBadWeatherEnabled,
    required this.groceryMaxWeight,
    required this.groceryAdditionalPrice,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryPrices &&
          runtimeType == other.runtimeType &&
          deliveryStartPrice == other.deliveryStartPrice &&
          deliveryPricePerKm == other.deliveryPricePerKm &&
          deliveryBadWeatherTax == other.deliveryBadWeatherTax &&
          deliveryMaximalPrice == other.deliveryMaximalPrice &&
          deliveryBadWeatherEnabled == other.deliveryBadWeatherEnabled &&
          groceryMaxWeight == other.groceryMaxWeight &&
          groceryAdditionalPrice == other.groceryAdditionalPrice);

  @override
  int get hashCode =>
      deliveryStartPrice.hashCode ^
      deliveryPricePerKm.hashCode ^
      deliveryBadWeatherTax.hashCode ^
      deliveryMaximalPrice.hashCode ^
      deliveryBadWeatherEnabled.hashCode ^
      groceryMaxWeight.hashCode ^
      groceryAdditionalPrice.hashCode;

  @override
  String toString() {
    return 'DeliveryPrices{' +
        ' deliveryStartPrice: $deliveryStartPrice,' +
        ' deliveryPricePerKm: $deliveryPricePerKm,' +
        ' deliveryBadWeatherTax: $deliveryBadWeatherTax,' +
        ' deliveryMaximalPrice: $deliveryMaximalPrice,' +
        ' deliveryBadWeatherEnabled: $deliveryBadWeatherEnabled,' +
        ' groceryMaxWeight: $groceryMaxWeight,' +
        ' groceryAdditionalPrice: $groceryAdditionalPrice,' +
        '}';
  }

  DeliveryPrices copyWith({
    double? deliveryStartPrice,
    double? deliveryPricePerKm,
    double? deliveryBadWeatherTax,
    double? deliveryMaximalPrice,
    bool? deliveryBadWeatherEnabled,
    double? groceryMaxWeight,
    double? groceryAdditionalPrice,
  }) {
    return DeliveryPrices(
      deliveryStartPrice: deliveryStartPrice ?? this.deliveryStartPrice,
      deliveryPricePerKm: deliveryPricePerKm ?? this.deliveryPricePerKm,
      deliveryBadWeatherTax:
          deliveryBadWeatherTax ?? this.deliveryBadWeatherTax,
      deliveryMaximalPrice: deliveryMaximalPrice ?? this.deliveryMaximalPrice,
      deliveryBadWeatherEnabled:
          deliveryBadWeatherEnabled ?? this.deliveryBadWeatherEnabled,
      groceryMaxWeight: groceryMaxWeight ?? this.groceryMaxWeight,
      groceryAdditionalPrice:
          groceryAdditionalPrice ?? this.groceryAdditionalPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deliveryStartPrice': deliveryStartPrice,
      'deliveryPricePerKm': deliveryPricePerKm,
      'deliveryBadWeatherTax': deliveryBadWeatherTax,
      'deliveryMaximalPrice': deliveryMaximalPrice,
      'deliveryBadWeatherEnabled': deliveryBadWeatherEnabled,
      'groceryMaxWeight': groceryMaxWeight,
      'groceryAdditionalPrice': groceryAdditionalPrice,
    };
  }

  factory DeliveryPrices.fromMap(Map<String, dynamic> map) {
    return DeliveryPrices(
      deliveryStartPrice: double.parse(map['deliveryStartPrice'].toString()),
      deliveryPricePerKm: double.parse(map['deliveryPricePerKm'].toString()),
      deliveryBadWeatherTax:
          double.parse(map['deliveryBadWeatherTax'].toString()),
      deliveryMaximalPrice:
          double.parse(map['deliveryMaximalPrice'].toString()),
      deliveryBadWeatherEnabled: map['deliveryBadWeatherEnabled'] ?? false,
      groceryMaxWeight: double.parse(map['groceryMaxWeight'].toString()),
      groceryAdditionalPrice:
          double.parse(map['groceryAdditionalPrice'].toString()),
    );
  }

//</editor-fold>
}

class DefaultDeliveryPrices extends DeliveryPrices {
  DefaultDeliveryPrices()
      : super(
          deliveryStartPrice: 3.0,
          deliveryPricePerKm: 2.0,
          deliveryBadWeatherTax: 0.0,
          deliveryMaximalPrice: 40.0,
          deliveryBadWeatherEnabled: false,
          groceryMaxWeight: 15.0,
          groceryAdditionalPrice: 10.0,
        );
}

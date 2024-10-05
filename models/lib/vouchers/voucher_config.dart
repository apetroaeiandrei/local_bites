import 'package:models/vouchers/voucher_type.dart';

class VoucherConfig {
  final VoucherType type;
  final String name;
  final String description;
  final int value;
  final num minPurchase;
  final int valabilityDays;
  final bool enabled;

//<editor-fold desc="Data Methods">
  const VoucherConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.value,
    required this.minPurchase,
    required this.valabilityDays,
    required this.enabled,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoucherConfig &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          name == other.name &&
          description == other.description &&
          value == other.value &&
          minPurchase == other.minPurchase &&
          valabilityDays == other.valabilityDays &&
          enabled == other.enabled);

  @override
  int get hashCode =>
      type.hashCode ^
      name.hashCode ^
      description.hashCode ^
      value.hashCode ^
      minPurchase.hashCode ^
      valabilityDays.hashCode ^
      enabled.hashCode;

  @override
  String toString() {
    return 'VoucherConfig{' +
        ' type: $type,' +
        ' name: $name,' +
        ' description: $description,' +
        ' value: $value,' +
        ' minPurchase: $minPurchase,' +
        ' valabilityDays: $valabilityDays,' +
        ' enabled: $enabled,' +
        '}';
  }

  VoucherConfig copyWith({
    VoucherType? type,
    String? name,
    String? description,
    int? value,
    num? minPurchase,
    int? valabilityDays,
    bool? enabled,
  }) {
    return VoucherConfig(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      minPurchase: minPurchase ?? this.minPurchase,
      valabilityDays: valabilityDays ?? this.valabilityDays,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toSimpleString(),
      'name': name,
      'description': description,
      'value': value,
      'minPurchase': minPurchase,
      'valabilityDays': valabilityDays,
      'enabled': enabled,
    };
  }

  factory VoucherConfig.fromMap(Map<String, dynamic> map) {
    return VoucherConfig(
      type: VoucherTypeExtension.fromString(map['type'] as String),
      name: map['name'] as String,
      description: map['description'] as String,
      value: map['value'] as int,
      minPurchase: map['minPurchase'] as num,
      valabilityDays: map['valabilityDays'] as int,
      enabled: map['enabled'] as bool,
    );
  }

//</editor-fold>
}

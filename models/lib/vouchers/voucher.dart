import 'package:models/vouchers/voucher_type.dart';

abstract class Voucher {
  final String id;
  final String name;
  final String description;
  final double value;
  final num minPurchase;
  final DateTime issueDate;
  final DateTime expiryDate;
  final bool isUsed;

  VoucherType get type;

//<editor-fold desc="Data Methods">
  const Voucher({
    required this.id,
    required this.name,
    required this.description,
    required this.value,
    required this.minPurchase,
    required this.issueDate,
    required this.expiryDate,
    required this.isUsed,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Voucher &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          value == other.value &&
          minPurchase == other.minPurchase &&
          issueDate == other.issueDate &&
          expiryDate == other.expiryDate &&
          isUsed == other.isUsed);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      value.hashCode ^
      minPurchase.hashCode ^
      issueDate.hashCode ^
      expiryDate.hashCode ^
      isUsed.hashCode;

  @override
  String toString() {
    return 'Voucher{' +
        ' id: $id,' +
        ' name: $name,' +
        ' description: $description,' +
        ' value: $value,' +
        ' minPurchase: $minPurchase,' +
        ' issueDate: $issueDate,' +
        ' expiryDate: $expiryDate,' +
        ' isUsed: $isUsed,' +
        '}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'value': value,
      'minPurchase': minPurchase,
      'issueDate': issueDate,
      'expiryDate': expiryDate,
      'isUsed': isUsed,
    };
  }

//</editor-fold>
}

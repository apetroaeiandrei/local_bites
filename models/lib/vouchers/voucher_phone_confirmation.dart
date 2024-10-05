import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:models/vouchers/voucher.dart';
import 'package:models/vouchers/voucher_type.dart';

class VoucherPhoneConfirmation extends Voucher{
  @override
  VoucherType get type => VoucherType.phoneConfirmation;

const VoucherPhoneConfirmation({
    required String id,
    required String name,
    required String description,
    required double value,
    required num minPurchase,
    required DateTime issueDate,
    required DateTime expiryDate,
    required bool isUsed,
  }) : super(
    id: id,
    name: name,
    description: description,
    value: value,
    minPurchase: minPurchase,
    issueDate: issueDate,
    expiryDate: expiryDate,
    isUsed: isUsed,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoucherPhoneConfirmation &&
          runtimeType == other.runtimeType &&
          super == other);

  @override
  int get hashCode => super.hashCode ^ type.hashCode;

  VoucherPhoneConfirmation copyWith({
    String? id,
    String? name,
    String? description,
    double? value,
    num? minPurchase,
    DateTime? issueDate,
    DateTime? expiryDate,
    bool? isUsed,
  }) {
    return VoucherPhoneConfirmation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      minPurchase: minPurchase ?? this.minPurchase,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isUsed: isUsed ?? this.isUsed,
    );
  }

  factory VoucherPhoneConfirmation.fromMap(Map<String, dynamic> map) {
    return VoucherPhoneConfirmation(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      value:  double.parse(map['value'].toString()),
      minPurchase: map['minPurchase'] as num,
      issueDate: (map['issueDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      isUsed: map['isUsed'] as bool,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:models/vouchers/voucher.dart';
import 'package:models/vouchers/voucher_type.dart';

class VoucherReferral extends Voucher {
  final String referralName;

  @override
  VoucherType get type => VoucherType.referral;

  const VoucherReferral({
    required String id,
    required String name,
    required String description,
    required double value,
    required num minPurchase,
    required DateTime issueDate,
    required DateTime expiryDate,
    required bool isUsed,
    required this.referralName,
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
      (other is VoucherReferral &&
          runtimeType == other.runtimeType &&
          referralName == other.referralName &&
          super == other);

  @override
  int get hashCode => super.hashCode ^ type.hashCode ^ referralName.hashCode;

  VoucherReferral copyWith({
    String? id,
    String? name,
    String? description,
    double? value,
    num? minPurchase,
    DateTime? issueDate,
    DateTime? expiryDate,
    bool? isUsed,
    String? referralName,
  }) {
    return VoucherReferral(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      minPurchase: minPurchase ?? this.minPurchase,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isUsed: isUsed ?? this.isUsed,
      referralName: referralName ?? this.referralName,
    );
  }

  factory VoucherReferral.fromMap(Map<String, dynamic> map) {
    return VoucherReferral(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      value: double.parse(map['value'].toString()),
      minPurchase: map['minPurchase'] as num,
      issueDate: (map['issueDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      isUsed: map['isUsed'] as bool,
      referralName: map['referralName'] as String,
    );
  }
}

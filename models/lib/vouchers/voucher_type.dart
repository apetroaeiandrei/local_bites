enum VoucherType {
  phoneConfirmation,
  referral,
}

extension VoucherTypeExtension on VoucherType {
  String toSimpleString() {
    return toString().split('.').last;
  }

  static VoucherType fromString(String? value) {
    switch (value) {
      case 'phoneConfirmation':
        return VoucherType.phoneConfirmation;
      case 'referral':
        return VoucherType.referral;
      default:
        return VoucherType.phoneConfirmation;
    }
  }
}

import 'package:models/vouchers/voucher.dart';
import 'package:models/vouchers/voucher_phone_confirmation.dart';
import 'package:models/vouchers/voucher_type.dart';

class VoucherFactory {
  static Voucher parse(Map<String, dynamic> json) {
    VoucherType type = VoucherTypeExtension.fromString(json['type']);
    switch (type) {
      case VoucherType.phoneConfirmation:
        return VoucherPhoneConfirmation.fromMap(json);
      case VoucherType.referral:
        //todo
        return VoucherPhoneConfirmation.fromMap(json);
    }
  }
}

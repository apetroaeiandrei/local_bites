part of 'vouchers_cubit.dart';

class VouchersState extends Equatable {
  final bool phoneVerified;
  final List<Voucher> vouchers;
  final bool referralEnabled;
  final num referralValue;
  final String referralCode;
  final num phoneConfirmValue;

  @override
  List<Object> get props => [
        phoneVerified,
        vouchers,
        referralEnabled,
        referralValue,
        referralCode,
        phoneConfirmValue,
      ];

  const VouchersState({
    required this.phoneVerified,
    required this.vouchers,
    required this.referralEnabled,
    required this.referralValue,
    required this.referralCode,
    required this.phoneConfirmValue,
  });

  VouchersState copyWith({
    bool? phoneVerified,
    List<Voucher>? vouchers,
    bool? referralEnabled,
    num? referralValue,
    String? referralCode,
    num? phoneConfirmValue,
  }) {
    return VouchersState(
      phoneVerified: phoneVerified ?? this.phoneVerified,
      vouchers: vouchers ?? this.vouchers,
      referralEnabled: referralEnabled ?? this.referralEnabled,
      referralValue: referralValue ?? this.referralValue,
      referralCode: referralCode ?? this.referralCode,
      phoneConfirmValue: phoneConfirmValue ?? this.phoneConfirmValue,
    );
  }
}

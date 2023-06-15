part of 'vouchers_cubit.dart';

class VouchersState extends Equatable {
  final bool phoneVerified;
  final List<Voucher> vouchers;

  @override
  List<Object> get props => [phoneVerified, vouchers];

  const VouchersState({
    required this.phoneVerified,
    required this.vouchers,
  });

  VouchersState copyWith({
    bool? phoneVerified,
    List<Voucher>? vouchers,
  }) {
    return VouchersState(
      phoneVerified: phoneVerified ?? this.phoneVerified,
      vouchers: vouchers ?? this.vouchers,
    );
  }
}

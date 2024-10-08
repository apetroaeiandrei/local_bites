import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/user_repo.dart';
import 'package:local/repos/vouchers_repo.dart';
import 'package:models/vouchers/voucher.dart';
import 'package:models/vouchers/voucher_type.dart';

part 'vouchers_state.dart';

class VouchersCubit extends Cubit<VouchersState> {
  VouchersCubit(this._userRepo, this._vouchersRepo)
      : super(VouchersState(
          phoneVerified: _userRepo.user!.phoneVerified,
          vouchers: List.from(_vouchersRepo.vouchers),
          referralEnabled: false,
          referralValue: 0,
          referralCode: _userRepo.user!.referralCode,
          phoneConfirmValue: 11,
        )) {
    _init();
  }

  final UserRepo _userRepo;
  final VouchersRepo _vouchersRepo;
  StreamSubscription? _voucherSubscription;
  StreamSubscription? _userSubscription;

  _init() {
    _voucherSubscription = _vouchersRepo.vouchersStream.listen((vouchers) {
      emit(state.copyWith(vouchers: vouchers));
    });
    _userSubscription = _userRepo.userStream.listen((user) {
      emit(state.copyWith(phoneVerified: user.phoneVerified));
      _checkReferralEnabled();
    });
    _checkReferralEnabled();
  }

  _checkReferralEnabled() {
    bool referralEnabled = false;
    num referralValue = 0;
    num phoneConfirmValue = 0;
    for (var element in _vouchersRepo.vouchersConfig) {
      if (element.type == VoucherType.referral) {
        referralEnabled = element.enabled && state.phoneVerified;
        referralValue = element.value;
      }
      if (element.type == VoucherType.phoneConfirmation) {
        phoneConfirmValue = element.value;
      }
    }
    Future.delayed(Duration.zero, () {
      emit(state.copyWith(
        referralEnabled: referralEnabled,
        referralValue: referralValue,
        phoneConfirmValue: phoneConfirmValue,
      ));
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _voucherSubscription?.cancel();
    return super.close();
  }
}

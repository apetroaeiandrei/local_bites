import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/vouchers/voucher.dart';
import 'package:models/vouchers/voucher_type.dart';

part 'vouchers_state.dart';

class VouchersCubit extends Cubit<VouchersState> {
  VouchersCubit(this._userRepo)
      : super(VouchersState(
          phoneVerified: _userRepo.user!.phoneVerified,
          vouchers: List.from(_userRepo.vouchers),
          referralEnabled: false,
          referralValue: 0,
          referralCode: _userRepo.user!.referralCode,
        )) {
    _init();
  }

  final UserRepo _userRepo;
  StreamSubscription? _voucherSubscription;
  StreamSubscription? _userSubscription;

  _init() {
    _voucherSubscription = _userRepo.vouchersStream.listen((vouchers) {
      emit(state.copyWith(vouchers: vouchers));
    });
    _userSubscription = _userRepo.userStream.listen((user) {
      emit(state.copyWith(phoneVerified: user.phoneVerified));
      _checkReferralEnabled();
    });
    _checkReferralEnabled();
  }

  _checkReferralEnabled() {
    for (var element in _userRepo.vouchersConfig) {
      if (element.type == VoucherType.referral) {
        Future.delayed(Duration.zero, () {
          emit(state.copyWith(
              referralEnabled: element.enabled, referralValue: element.value));
        });
      }
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _voucherSubscription?.cancel();
    return super.close();
  }
}

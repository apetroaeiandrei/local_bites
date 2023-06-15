import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/vouchers/voucher.dart';

part 'vouchers_state.dart';

class VouchersCubit extends Cubit<VouchersState> {
  VouchersCubit(this._userRepo)
      : super(VouchersState(phoneVerified: _userRepo.user!.phoneVerified, vouchers: _userRepo.vouchers));

  final UserRepo _userRepo;
}

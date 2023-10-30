import 'package:bloc/bloc.dart';
import 'package:local/profile/profile_state.dart';
import 'package:local/repos/auth_repo.dart';
import 'package:local/repos/notifications_repo.dart';
import 'package:local/repos/user_repo.dart';

import '../repos/vouchers_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._userRepo,
    this._authRepo,
    this._notificationsRepo,
    this._vouchersRepo,
    bool firstTime,
  ) : super(ProfileState(
          status: ProfileStatus.initial,
          name: _userRepo.user?.name ?? "",
          firstTime: firstTime,
        )) {
    init();
  }

  final UserRepo _userRepo;
  final AuthRepo _authRepo;
  final NotificationsRepo _notificationsRepo;
  final VouchersRepo _vouchersRepo;

  init() {
    Future.delayed(const Duration(milliseconds: 10), () {
      emit(state.copyWith(name: _userRepo.user?.name ?? ""));
    });
  }

  setUserDetails(String name, {String referredBy = ""}) async {
    final success =
        await _userRepo.updateUserDetails(name: name, referredBy: referredBy);
    emit(state.copyWith(
      status: success ? ProfileStatus.success : ProfileStatus.failure,
    ));
  }

  Future<void> deleteUser() async {
    final success = await _authRepo.deleteUser();
    if (success) {
      _onLogout();
    }
    emit(state.copyWith(
        status:
            success ? ProfileStatus.deleted : ProfileStatus.deletedFailure));
  }

  void retry() {
    emit(state.copyWith(status: ProfileStatus.initial));
  }

  _onLogout() async {
    await _userRepo.onLogout();
    await _notificationsRepo.onLogout();
    await _vouchersRepo.onLogout();
  }
}

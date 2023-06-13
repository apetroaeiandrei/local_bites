import 'package:bloc/bloc.dart';
import 'package:local/profile/profile_state.dart';
import 'package:local/repos/user_repo.dart';
import 'package:local/utils.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._userRepo,
  ) : super(ProfileState(
          status: ProfileStatus.initial,
          name: _userRepo.user?.name ?? "",
        )) {
    init();
  }

  final UserRepo _userRepo;

  init() {
    Future.delayed(const Duration(milliseconds: 10), () {
      emit(state.copyWith(name: _userRepo.user?.name ?? ""));
    });
  }

  setUserDetails(
    String name,
  ) async {
    final success = await _userRepo.setUserDetails(name);
    emit(state.copyWith(
      status: success ? ProfileStatus.success : ProfileStatus.failure,
    ));
  }

  Future<void> deleteUser() async {
    final success = await _userRepo.deleteUser();
    emit(state.copyWith(
        status:
            success ? ProfileStatus.deleted : ProfileStatus.deletedFailure));
  }
}

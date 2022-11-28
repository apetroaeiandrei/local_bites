import 'package:bloc/bloc.dart';
import 'package:local/profile/profile_state.dart';
import 'package:local/repos/user_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._userRepo,
  ) : super(ProfileState(
            status: ProfileStatus.initial,
            name: _userRepo.user?.name ?? "",
            phoneNumber: _userRepo.user?.phoneNumber ?? "")) {
    init();
  }
  final UserRepo _userRepo;

  init() {
    Future.delayed(const Duration(milliseconds: 10), () {
      emit(state.copyWith(
          name: _userRepo.user?.name ?? "",
          phoneNumber: _userRepo.user?.phoneNumber ?? ""));
    });
  }

  setUserDetails(String name, String phoneNumber) async {
    final success = await _userRepo.setUserDetails(name, phoneNumber);
    emit(state.copyWith(
      status: success ? ProfileStatus.success : ProfileStatus.failure,
    ));
  }
}

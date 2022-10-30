import 'package:bloc/bloc.dart';
import 'package:local/profile/profile_state.dart';
import 'package:local/repos/user_repo.dart';
import '../auth/auth_status.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._userRepo,
  ) : super(const ProfileState(status: ProfileStatus.initial));
  final UserRepo _userRepo;

  setUserDetails(String name, String phoneNumber) async {
    final success = await _userRepo.setUserDetails(name,  phoneNumber);
    emit(state.copyWith(
      status: success ? ProfileStatus.success : ProfileStatus.failure,
    ));
  }
}

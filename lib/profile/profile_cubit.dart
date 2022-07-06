import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local/profile/profile_state.dart';
import 'package:local/repos/user_repo.dart';
import '../repos/auth_repo.dart';
import '../auth/auth_status.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._userRepo,)
      : super(const ProfileState(status: AuthStatus.initial));
  final UserRepo _userRepo;

  setUserDetails(String name, String address, String phoneNumber) async {
    final success = await _userRepo.setUserDetails(name, address, phoneNumber);
    emit(state.copyWith(
      status: success ? AuthStatus.authorized : AuthStatus.unauthorized,
    ));
  }
}

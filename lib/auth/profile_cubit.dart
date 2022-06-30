import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../repos/auth_repo.dart';
import 'auth_status.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._authRepo)
      : super(const ProfileState(status: AuthStatus.initial));
  final AuthRepo _authRepo;

  setUserDetails(String name, String address, String phoneNumber) async {
    final success = await _authRepo.setUserDetails(name, address, phoneNumber);
    emit(state.copyWith(
      status: success ? AuthStatus.authorized : AuthStatus.unauthorized,
    ));
  }
}

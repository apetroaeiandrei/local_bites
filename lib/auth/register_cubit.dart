import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../repos/auth_repo.dart';
import 'auth_status.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._authRepo)
      : super(const RegisterState(status: AuthStatus.initial));
  final AuthRepo _authRepo;

  register(String email, String password) async {
    final success = await _authRepo.register(email, password);
    emit(state.copyWith(
      status: success ? AuthStatus.authorized : AuthStatus.unauthorized,
    ));
  }

  setUserDetails(String name, String address, String phoneNumber) async {
    final success = await _authRepo.setUserDetails(name, address, phoneNumber);
    emit(state.copyWith(
      status: success ? AuthStatus.authorized : AuthStatus.unauthorized,
    ));
  }
}

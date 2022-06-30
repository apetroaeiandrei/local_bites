import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repos/auth_repo.dart';
import 'auth_status.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepo) : super(const AuthState(status: AuthStatus.initial));
  final AuthRepo _authRepo;

  register(String email, String password) async {
    final success = await _authRepo.register(email, password);
    emit(state.copyWith(
      status: success ? AuthStatus.registeredSuccessfully : AuthStatus.unauthorized,
    ));
  }

  login(String email, String password) async {
    final success = await _authRepo.login(email, password);
    emit(state.copyWith(
      status: success ? AuthStatus.authorized : AuthStatus.unauthorized,
    ));
  }
}

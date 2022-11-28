import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/repos/user_repo.dart';

import '../repos/auth_repo.dart';
import 'auth_status.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepo, this._userRepo) : super(const AuthState(status: AuthStatus.initial));
  final AuthRepo _authRepo;
  final UserRepo _userRepo;

  register(String email, String password) async {
    final success = await _authRepo.register(email, password);
    emit(state.copyWith(
      status: success ? AuthStatus.authorized : AuthStatus.unauthorized,
    ));
  }

  login(String email, String password) async {
    final success = await _authRepo.login(email, password);
    await _userRepo.getUser();
    emit(state.copyWith(
      status: success ? AuthStatus.authorized : AuthStatus.unauthorized,
    ));
  }

  loginAnonymously() async {
    final success = await _authRepo.loginAnonymously();
    emit(state.copyWith(
      status: success ? AuthStatus.authorized : AuthStatus.unauthorized,
    ));
  }
}

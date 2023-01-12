import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/auth_repo.dart';
import 'package:local/repos/user_repo.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._authRepo, this._userRepo)
      : super(const RegisterState(status: RegisterStatus.initial));
  final AuthRepo _authRepo;
  final UserRepo _userRepo;

  register(
      {required String email,
      required String password,
      required String name,
      required String phone}) async {
    final success = await _authRepo.register(email, password);
    if (success) {
      final userSuccess = await _userRepo.setUserDetails(name, phone);
      emit(state.copyWith(
        status: userSuccess ? RegisterStatus.success : RegisterStatus.failure,
      ));
    } else {
      emit(state.copyWith(status: RegisterStatus.failure));
    }
  }

  void onDialogClosed() {
    emit(state.copyWith(status: RegisterStatus.initial));
  }
}

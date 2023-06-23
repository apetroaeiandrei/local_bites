import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/repos/phone_confirm_error.dart';
import 'package:local/repos/user_repo.dart';

import '../repos/auth_repo.dart';
import 'auth_status.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._authRepo,
  ) : super(const AuthState(
            status: AuthStatus.initial, phoneConfirmError: null));
  final AuthRepo _authRepo;

  login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loadingEmail));
    final success = await _authRepo.login(email, password);
    emit(state.copyWith(
      status:
          success ? AuthStatus.authorized : AuthStatus.invalidEmailCredentials,
    ));
  }

  onFocusChanged() {
    emit(state.copyWith(status: AuthStatus.initial));
  }

  void confirm(String smsCode) {
    emit(state.copyWith(status: AuthStatus.phoneCodeSentByUser));
    _authRepo.confirmCodeAndSignIn(
      smsCode: smsCode,
      verificationId: verificationId,
      onError: (error) {
        _handlePhoneAuthError(error);
      },
      onSuccess: () {
        emit(state.copyWith(status: AuthStatus.phoneCodeConfirmed));
      },
    );
  }

  String verificationId = '';

  void loginWithPhone(String phoneNumber) {
    emit(state.copyWith(status: AuthStatus.phoneCodeRequested));
    _authRepo.loginWithPhone(
      linkCredential: false,
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        print('on code sent - verificationId: $verificationId');
        emit(state.copyWith(status: AuthStatus.phoneCodeSent));
        this.verificationId = verificationId;
      },
      onError: (error, {verificationId}) {
        _handlePhoneAuthError(error, verificationId: verificationId);
        print('on error');
      },
      onSuccess: () {
        print('on success');
        emit(state.copyWith(status: AuthStatus.phoneCodeConfirmed));
      },
    );
  }

  _handlePhoneAuthError(PhoneConfirmError error, {String? verificationId}) {
    if (error == PhoneConfirmError.timeout &&
        state.status == AuthStatus.phoneAuthError) {
      return;
    }
    if (isClosed) {
      return;
    }
    if (error == PhoneConfirmError.invalidCode) {
      emit(state.copyWith(
        status: AuthStatus.phoneCodeInvalid,
        phoneConfirmError: error,
      ));
      return;
    }
    emit(state.copyWith(
      status: AuthStatus.phoneAuthError,
      phoneConfirmError: error,
    ));
  }

  void retry() {
    emit(state.copyWith(status: AuthStatus.initial));
  }

  Future<void> resetPassword(String text) async {
    final success = await _authRepo.sendPasswordReset(text);
    emit(state.copyWith(
      status: success
          ? AuthStatus.passwordResetRequested
          : AuthStatus.passwordResetError,
    ));
  }
}

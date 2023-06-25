import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/repos/phone_confirm_error.dart';

import '../analytics/metric.dart';
import '../repos/auth_repo.dart';
import 'auth_status.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._authRepo,
    this._analytics,
  ) : super(const AuthState(
            status: AuthStatus.initial, phoneConfirmError: null));
  final AuthRepo _authRepo;
  final Analytics _analytics;

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
        _analytics.logEvent(name: Metric.eventPhoneLoginSuccess);
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
        emit(state.copyWith(status: AuthStatus.phoneCodeSent));
        this.verificationId = verificationId;
      },
      onError: (error, {verificationId}) {
        _handlePhoneAuthError(error, verificationId: verificationId);
      },
      onSuccess: () {
        _analytics.logEvent(name: Metric.eventPhoneLoginSuccess);
        emit(state.copyWith(status: AuthStatus.phoneCodeConfirmed));
      },
    );
  }

  _handlePhoneAuthError(PhoneConfirmError error, {String? verificationId}) {
    _analytics
        .logEventWithParams(name: Metric.eventPhoneLoginError, parameters: {
      Metric.propertyError: error.toString(),
    });
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
    _analytics.logEvent(name: Metric.eventPhoneLoginRetry);
    emit(state.copyWith(status: AuthStatus.initial));
  }

  Future<void> resetPassword(String text) async {
    _analytics.logEvent(name: Metric.eventAuthPasswordReset);
    final success = await _authRepo.sendPasswordReset(text);
    emit(state.copyWith(
      status: success
          ? AuthStatus.passwordResetRequested
          : AuthStatus.passwordResetError,
    ));
  }
}

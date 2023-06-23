import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/auth/auth_status.dart';

import '../../repos/auth_repo.dart';
import '../../repos/phone_confirm_error.dart';
import '../../utils.dart';

part 'delete_account_confirm_state.dart';

class DeleteAccountConfirmCubit extends Cubit<DeleteAccountConfirmState> {
  DeleteAccountConfirmCubit(this._authRepo)
      : super(const DeleteAccountConfirmState(
          status: AuthStatus.initial,
          hasEmailCredential: false,
          hasPhoneCredential: false,
          phoneNumber: "",
          email: "",
        )) {
    _init();
  }

  final AuthRepo _authRepo;
  String verificationId = '';

  _init() async {
    final providers = _authRepo.getUserProviders();
    var hasEmailCredential = false;
    var hasPhoneCredential = false;
    var phoneNumber = "";
    var email = "";

    providers?.forEach((element) {
      if (element.providerId == 'phone') {
        hasPhoneCredential = true;
        phoneNumber = Utils.formatPhoneNumberForIntl(element.phoneNumber!);
      }
      if (element.providerId == 'password') {
        hasEmailCredential = true;
        email = element.email!;
      }
      print(element);
    });
    Future.delayed(const Duration(milliseconds: 10), () {
      emit(state.copyWith(
        hasEmailCredential: hasEmailCredential,
        hasPhoneCredential: hasPhoneCredential,
        phoneNumber: phoneNumber,
        email: email,
      ));
    });
  }

  login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loadingEmail));
    final success =
        await _authRepo.login(email, password, reauthenticate: true);
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
      reauthenticate: true,
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

  void loginWithPhone(String phoneNumber) {
    print("loginWithPhone - phoneNumber: $phoneNumber");
    emit(state.copyWith(status: AuthStatus.phoneCodeRequested));
    _authRepo.loginWithPhone(
      reauthenticate: true,
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

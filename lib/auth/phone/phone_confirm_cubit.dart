import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/phone_confirm_error.dart';
import 'package:local/repos/auth_repo.dart';
import 'package:local/repos/user_repo.dart';

part 'phone_confirm_state.dart';

class PhoneConfirmCubit extends Cubit<PhoneConfirmState> {
  PhoneConfirmCubit(this._authRepo, this._userRepo)
      : super(const PhoneConfirmState(
          status: PhoneConfirmStatus.initial,
          phoneNumber: '',
        )) {
    _init();
  }

  final AuthRepo _authRepo;
  final UserRepo _userRepo;
  String verificationId = '';

  _init() async {
    Future.delayed(const Duration(milliseconds: 10), () {
      var phone = _userRepo.user?.phoneNumber ?? '';
      if (phone.startsWith('0')) {
        phone = phone.substring(1);
      }
      emit(
        state.copyWith(
          status: PhoneConfirmStatus.phoneLoaded,
          phoneNumber: phone,
        ),
      );
    });
  }

  void retry() {
    emit(state.copyWith(status: PhoneConfirmStatus.initial));
  }

  void confirmCode(String smsCode) {
    _authRepo.confirmCode(
      smsCode: smsCode,
      verificationId: verificationId,
      onError: (error) {
        _handleError(error);
      },
      onSuccess: () {
        emit(state.copyWith(status: PhoneConfirmStatus.codeConfirmed));
      },
    );
  }

  void requestCode(String phoneNumber) {
    emit(state.copyWith(status: PhoneConfirmStatus.codeRequested));
    _authRepo.loginWithPhone(
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        this.verificationId = verificationId;
        emit(state.copyWith(
          status: PhoneConfirmStatus.codeSent,
        ));
      },
      onError: (error) {
        _handleError(error);
      },
      onSuccess: () {
        emit(state.copyWith(status: PhoneConfirmStatus.codeConfirmed));
      },
    );
  }

  _handleError(PhoneConfirmError error) {
    if (error == PhoneConfirmError.timeout &&
        state.status == PhoneConfirmStatus.failure) {
      return;
    }
    emit(state.copyWith(status: PhoneConfirmStatus.failure, error: error));
  }
}

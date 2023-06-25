import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/analytics/metric.dart';
import 'package:local/repos/phone_confirm_error.dart';
import 'package:local/repos/auth_repo.dart';
import 'package:local/repos/user_repo.dart';

import '../../utils.dart';

part 'phone_confirm_state.dart';

class PhoneConfirmCubit extends Cubit<PhoneConfirmState> {
  PhoneConfirmCubit(this._authRepo, this._userRepo, this._analytics)
      : super(const PhoneConfirmState(
          status: PhoneConfirmStatus.initial,
          phoneNumber: '',
        )) {
    _init();
  }

  final AuthRepo _authRepo;
  final UserRepo _userRepo;
  final Analytics _analytics;
  String verificationId = '';

  _init() async {
    Future.delayed(const Duration(milliseconds: 10), () {
      var phone =
          Utils.formatPhoneNumberForIntl(_userRepo.user?.phoneNumber ?? '');
      emit(
        state.copyWith(
          status: PhoneConfirmStatus.phoneLoaded,
          phoneNumber: phone,
        ),
      );
    });
  }

  void retry() {
    _analytics.logEvent(name: Metric.eventPhoneConfirmRetry);
    emit(state.copyWith(status: PhoneConfirmStatus.initial));
  }

  void confirmCode(String smsCode) {
    emit(state.copyWith(status: PhoneConfirmStatus.codeSentByUser));
    _authRepo.confirmCodeAndLinkCredential(
      smsCode: smsCode,
      verificationId: verificationId,
      onError: (error, {verificationId}) {
        _handleError(error, verificationId: verificationId);
      },
      onSuccess: () {
        _analytics.logEvent(name: Metric.eventPhoneConfirmSuccess);
        emit(state.copyWith(status: PhoneConfirmStatus.codeConfirmed));
      },
    );
  }

  void requestCode(String phoneNumber) {
    emit(state.copyWith(status: PhoneConfirmStatus.codeRequested));
    _analytics.logEvent(name: Metric.eventPhoneConfirmRequest);
    _authRepo.loginWithPhone(
      linkCredential: true,
      phoneNumber: phoneNumber,
      onCodeSent: (verificationId) {
        this.verificationId = verificationId;
        emit(state.copyWith(
          status: PhoneConfirmStatus.codeSent,
        ));
      },
      onError: (error, {verificationId}) {
        _handleError(error, verificationId: verificationId);
      },
      onSuccess: () {
        _analytics.logEvent(name: Metric.eventPhoneConfirmSuccess);
        emit(state.copyWith(status: PhoneConfirmStatus.codeConfirmed));
      },
    );
  }

  _handleError(PhoneConfirmError error, {String? verificationId}) {
    _analytics
        .logEventWithParams(name: Metric.eventPhoneConfirmError, parameters: {
      Metric.propertyError: error.toString(),
    });
    if (error == PhoneConfirmError.timeout &&
        state.status == PhoneConfirmStatus.failure) {
      return;
    }
    if (isClosed) {
      return;
    }
    if (error == PhoneConfirmError.invalidCode) {
      emit(state.copyWith(
        status: PhoneConfirmStatus.phoneCodeInvalid,
        error: error,
      ));
      return;
    }
    emit(state.copyWith(
      status: PhoneConfirmStatus.failure,
      error: error,
    ));
  }
}

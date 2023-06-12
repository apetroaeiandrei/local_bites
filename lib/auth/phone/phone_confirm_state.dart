part of 'phone_confirm_cubit.dart';

enum PhoneConfirmStatus {
  initial,
  phoneLoaded,
  codeRequested,
  codeSent,
  codeConfirmed,
  failure,
  phoneCodeInvalid, codeSentByUser,
}

class PhoneConfirmState extends Equatable {
  final PhoneConfirmStatus status;
  final PhoneConfirmError? error;
  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber, status, error];

  const PhoneConfirmState({
    required this.status,
    this.error,
    required this.phoneNumber,
  });

  PhoneConfirmState copyWith({
    PhoneConfirmStatus? status,
    PhoneConfirmError? error,
    String? phoneNumber,
  }) {
    return PhoneConfirmState(
      status: status ?? this.status,
      error: error ?? this.error,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

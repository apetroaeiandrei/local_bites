part of 'delete_account_confirm_cubit.dart';

class DeleteAccountConfirmState extends Equatable {
  final AuthStatus status;
  final bool hasEmailCredential;
  final bool hasPhoneCredential;
  final String phoneNumber;
  final String email;
  final PhoneConfirmError? phoneConfirmError;

  @override
  List<Object?> get props => [
        status,
        hasEmailCredential,
        hasPhoneCredential,
        phoneConfirmError,
        phoneNumber,
        email,
      ];

  const DeleteAccountConfirmState({
    required this.status,
    required this.hasEmailCredential,
    required this.hasPhoneCredential,
    required this.phoneNumber,
    required this.email,
    this.phoneConfirmError,
  });

  DeleteAccountConfirmState copyWith({
    AuthStatus? status,
    bool? hasEmailCredential,
    bool? hasPhoneCredential,
    String? phoneNumber,
    String? email,
    PhoneConfirmError? phoneConfirmError,
  }) {
    return DeleteAccountConfirmState(
      status: status ?? this.status,
      hasEmailCredential: hasEmailCredential ?? this.hasEmailCredential,
      hasPhoneCredential: hasPhoneCredential ?? this.hasPhoneCredential,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      phoneConfirmError: phoneConfirmError ?? this.phoneConfirmError,
    );
  }
}

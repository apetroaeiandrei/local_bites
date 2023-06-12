part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final AuthStatus status;
  final PhoneConfirmError? phoneConfirmError;

  @override
  List<Object?> get props => [status, phoneConfirmError];

  const AuthState({
    required this.status,
    required this.phoneConfirmError,
  });

  AuthState copyWith({
    AuthStatus? status,
    PhoneConfirmError? phoneConfirmError,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneConfirmError: phoneConfirmError ?? this.phoneConfirmError,
    );
  }
}

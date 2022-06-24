part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final AuthStatus status;

  @override
  List<Object> get props => [status];

  const AuthState({
    required this.status,
  });

  AuthState copyWith({
    AuthStatus? status,
  }) {
    return AuthState(
      status: status ?? this.status,
    );
  }
}

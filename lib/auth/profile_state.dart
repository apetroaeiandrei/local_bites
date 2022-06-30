part of 'profile_cubit.dart';

class RegisterState extends Equatable {
  final AuthStatus status;

  @override
  List<Object?> get props => [status];

  const RegisterState({required this.status});

  RegisterState copyWith({
    AuthStatus? status,
  }) {
    return RegisterState(
      status: status ?? this.status,
    );
  }
}

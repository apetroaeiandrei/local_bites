part of 'register_cubit.dart';

enum RegisterStatus { initial, success, failure }

class RegisterState extends Equatable {
  final RegisterStatus status;

  @override
  List<Object> get props => [status];

  const RegisterState({
    required this.status,
  });

  RegisterState copyWith({
    RegisterStatus? status,
  }) {
    return RegisterState(
      status: status ?? this.status,
    );
  }
}

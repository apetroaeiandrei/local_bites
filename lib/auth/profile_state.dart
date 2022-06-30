part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  final AuthStatus status;

  @override
  List<Object?> get props => [status];

  const ProfileState({required this.status});

  ProfileState copyWith({
    AuthStatus? status,
  }) {
    return ProfileState(
      status: status ?? this.status,
    );
  }
}

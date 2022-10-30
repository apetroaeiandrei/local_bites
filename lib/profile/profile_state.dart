import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;

  @override
  List<Object?> get props => [status];

  const ProfileState({required this.status});

  ProfileState copyWith({
    ProfileStatus? status,
  }) {
    return ProfileState(
      status: status ?? this.status,
    );
  }
}

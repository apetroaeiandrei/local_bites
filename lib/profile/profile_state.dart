import 'package:equatable/equatable.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  failure,
  deleted,
  deletedFailure
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final String name;

  @override
  List<Object?> get props => [status, name];

  const ProfileState({
    required this.status,
    required this.name,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? name,
  }) {
    return ProfileState(
      status: status ?? this.status,
      name: name ?? this.name,
    );
  }
}

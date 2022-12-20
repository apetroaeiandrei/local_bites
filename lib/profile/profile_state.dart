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
  final String phoneNumber;

  @override
  List<Object?> get props => [status, name, phoneNumber];

  const ProfileState({
    required this.status,
    required this.name,
    required this.phoneNumber,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? name,
    String? phoneNumber,
  }) {
    return ProfileState(
      status: status ?? this.status,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

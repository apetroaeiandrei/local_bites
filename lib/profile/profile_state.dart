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
  final bool firstTime;

  @override
  List<Object?> get props => [status, name, firstTime];

  const ProfileState({
    required this.status,
    required this.name,
    required this.firstTime,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    String? name,
    bool? firstTime,
  }) {
    return ProfileState(
      status: status ?? this.status,
      name: name ?? this.name,
      firstTime: firstTime ?? this.firstTime,
    );
  }
}

part of 'home_cubit.dart';

class HomeState extends Equatable {
  final HomeStatus status;

  @override
  List<Object> get props => [status];

  const HomeState({
    required this.status,
  });

  HomeState copyWith({
    HomeStatus? status,
  }) {
    return HomeState(
      status: status ?? this.status,
    );
  }
}

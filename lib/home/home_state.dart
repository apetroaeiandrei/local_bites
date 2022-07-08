part of 'home_cubit.dart';
enum HomeStatus {
  initial,
  loading,
  loaded,
  profileIncomplete,
  restaurantsError,
  error,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final List<RestaurantModel> restaurants;

  @override
  List<Object> get props => [status];

  const HomeState({
    required this.status,
    required this.restaurants,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<RestaurantModel>? restaurants,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
    );
  }
}

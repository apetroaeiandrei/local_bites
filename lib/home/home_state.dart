part of 'home_cubit.dart';
enum HomeStatus {
  initial,
  loading,
  loaded,
  profileIncomplete,
  restaurantsError,
  addressError,
  error,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final List<RestaurantModel> restaurants;
  final String? address;

  @override
  List<Object?> get props => [status, restaurants, address];

  const HomeState({
    required this.status,
    required this.restaurants,
    this.address,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<RestaurantModel>? restaurants,
    String? address,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      address: address ?? this.address,
    );
  }
}

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
  final UserOrder? currentOrder;
  final bool showCurrentOrder;

  @override
  List<Object?> get props => [status, restaurants, address, currentOrder, showCurrentOrder];

  const HomeState({
    required this.status,
    required this.restaurants,
    this.address,
    this.currentOrder,
    required this.showCurrentOrder,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<RestaurantModel>? restaurants,
    String? address,
    UserOrder? currentOrder,
    bool? showCurrentOrder,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      address: address ?? this.address,
      currentOrder: currentOrder ?? this.currentOrder,
      showCurrentOrder: showCurrentOrder ?? this.showCurrentOrder,
    );
  }
}

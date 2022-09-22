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
  final List<UserOrder> currentOrders;
  final bool showCurrentOrder;

  @override
  List<Object?> get props => [status, restaurants, address, currentOrders, showCurrentOrder];

  const HomeState({
    required this.status,
    required this.restaurants,
    this.address,
    required this.currentOrders,
    required this.showCurrentOrder,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<RestaurantModel>? restaurants,
    String? address,
    List<UserOrder>? currentOrders,
    bool? showCurrentOrder,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      address: address ?? this.address,
      currentOrders: currentOrders ?? this.currentOrders,
      showCurrentOrder: showCurrentOrder ?? this.showCurrentOrder,
    );
  }
}

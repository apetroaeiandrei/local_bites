part of 'home_cubit.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  profileIncomplete,
  restaurantsError,
  addressError,
  error,
  showSettingsNotification,
  showKnownNearestAddressDialog,
  showUnknownNearestAddressDialog,
  showLocationPermissionDialog,
}

class HomeState extends Equatable {
  final HomeStatus status;
  final List<RestaurantModel> restaurants;
  final DeliveryAddress? address;
  final List<UserOrder> currentOrders;
  final bool showCurrentOrder;
  final bool showNotificationsPrompt;
  final bool isNoGoZone;
  final DeliveryAddress? nearestDeliveryAddress;

  @override
  List<Object?> get props => [
        status,
        isNoGoZone,
        restaurants,
        address,
        currentOrders,
        showCurrentOrder,
        showNotificationsPrompt,
        nearestDeliveryAddress
      ];

  const HomeState({
    required this.status,
    required this.restaurants,
    this.address,
    required this.currentOrders,
    required this.showCurrentOrder,
    required this.showNotificationsPrompt,
    required this.isNoGoZone,
    this.nearestDeliveryAddress,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<RestaurantModel>? restaurants,
    DeliveryAddress? address,
    List<UserOrder>? currentOrders,
    bool? showCurrentOrder,
    bool? showNotificationsPrompt,
    bool? isNoGoZone,
    DeliveryAddress? nearestDeliveryAddress,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      address: address ?? this.address,
      currentOrders: currentOrders ?? this.currentOrders,
      showCurrentOrder: showCurrentOrder ?? this.showCurrentOrder,
      showNotificationsPrompt:
          showNotificationsPrompt ?? this.showNotificationsPrompt,
      isNoGoZone: isNoGoZone ?? this.isNoGoZone,
      nearestDeliveryAddress:
          nearestDeliveryAddress ?? this.nearestDeliveryAddress,
    );
  }
}

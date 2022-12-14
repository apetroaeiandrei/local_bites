part of 'order_cubit.dart';

enum OrderScreenStatus {
  initial,
  loading,
  loaded,
  error,
}

class OrderState extends Equatable {
  final OrderScreenStatus status;
  final Order? order;
  final RestaurantModel? restaurant;

  final double deliveryLatitude;
  final double deliveryLongitude;
  final String deliveryStreet;
  final String deliveryPropertyDetails;

  final double restaurantLatitude;
  final double restaurantLongitude;
  final String restaurantAddress;

  @override
  List<Object?> get props => [
        status,
        order,
        restaurant,
        deliveryLatitude,
        deliveryLongitude,
        deliveryStreet,
        deliveryPropertyDetails,
        restaurantLatitude,
        restaurantLongitude,
        restaurantAddress
      ];

  const OrderState({
    required this.status,
    this.order,
    this.restaurant,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.deliveryStreet,
    required this.deliveryPropertyDetails,
    required this.restaurantLatitude,
    required this.restaurantLongitude,
    required this.restaurantAddress,
  });

  OrderState copyWith({
    OrderScreenStatus? status,
    Order? order,
    RestaurantModel? restaurant,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? deliveryStreet,
    String? deliveryPropertyDetails,
    double? restaurantLatitude,
    double? restaurantLongitude,
    String? restaurantAddress,
  }) {
    return OrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      restaurant: restaurant ?? this.restaurant,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      deliveryStreet: deliveryStreet ?? this.deliveryStreet,
      deliveryPropertyDetails:
          deliveryPropertyDetails ?? this.deliveryPropertyDetails,
      restaurantLatitude: restaurantLatitude ?? this.restaurantLatitude,
      restaurantLongitude: restaurantLongitude ?? this.restaurantLongitude,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
    );
  }
}

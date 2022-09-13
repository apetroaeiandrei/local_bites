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

  @override
  List<Object?> get props => [status, order, restaurant];

  const OrderState({
    required this.status,
    this.order,
    this.restaurant,
  });

  OrderState copyWith({
    OrderScreenStatus? status,
    Order? order,
    RestaurantModel? restaurant,
  }) {
    return OrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      restaurant: restaurant ?? this.restaurant,
    );
  }
}

part of 'orders_cubit.dart';

enum OrdersStatus { loading, loaded, error}
class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<UserOrder> orders;

  @override
  List<Object> get props => [status, orders];

  const OrdersState({
    required this.status,
    required this.orders,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<UserOrder>? orders,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
    );
  }
}



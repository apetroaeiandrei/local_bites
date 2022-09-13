import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:models/order.dart';
import 'package:models/order_status.dart';
import 'package:models/restaurant_model.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit(
    this._ordersRepo,
    this._restaurantsRepo,
    this._orderId,
    this._restaurantId,
  ) : super(const OrderState(
          status: OrderScreenStatus.loading,
        )) {
    _init();
  }

  final OrdersRepo _ordersRepo;
  final RestaurantsRepo _restaurantsRepo;
  final String _orderId;
  final String _restaurantId;
  StreamSubscription? _orderSubscription;

  void _init() async {
    final order = await _ordersRepo.getOrder(_orderId, _restaurantId);
    final restaurant = await _restaurantsRepo.getRestaurantById(_restaurantId);
    if (order.status != OrderStatus.completed) {
      _orderSubscription = _ordersRepo
          .getOrderSnapshotsStream(_restaurantId, _orderId)
          .listen((event) {
        final order = Order.fromMap(event.data()!);
        emit(state.copyWith(order: order));
      });
    }
    emit(state.copyWith(
      status: OrderScreenStatus.loaded,
      order: order,
      restaurant: restaurant,
    ));
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:models/user_order.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._ordersRepo)
      : super(const OrdersState(status: OrdersStatus.loading, orders: [])) {
    init();
  }

  final OrdersRepo _ordersRepo;

  init() async {
    final orders = await _ordersRepo.getUserOrders();
    emit(state.copyWith(status: OrdersStatus.loaded, orders: orders));
  }
}

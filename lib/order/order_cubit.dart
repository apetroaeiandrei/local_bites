import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/order.dart';
import 'package:models/order_status.dart';
import 'package:models/restaurant_model.dart';
import 'package:url_launcher/url_launcher.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit(
    this._ordersRepo,
    this._restaurantsRepo,
    this._userRepo,
    this._orderId,
    this._restaurantId,
  ) : super(const OrderState(
          status: OrderScreenStatus.loading,
          deliveryLatitude: 0,
          deliveryLongitude: 0,
          deliveryStreet: '',
          deliveryPropertyDetails: '',
          restaurantLatitude: 0,
          restaurantLongitude: 0,
          restaurantAddress: '',
        )) {
    _init();
  }

  final OrdersRepo _ordersRepo;
  final RestaurantsRepo _restaurantsRepo;
  final UserRepo _userRepo;
  final String _orderId;
  final String _restaurantId;
  StreamSubscription? _orderSubscription;
  late final Order _order;
  void _init() async {
    _order = await _ordersRepo.getOrder(_orderId, _restaurantId);
    final restaurant = await _restaurantsRepo.getRestaurantById(_restaurantId);
    if (_order.status != OrderStatus.completed) {
      _orderSubscription = _ordersRepo
          .getOrderSnapshotsStream(_restaurantId, _orderId)
          .listen((event) {
        final order = Order.fromMap(event.data()!);
        emit(state.copyWith(order: order));
      });
    }
    emit(state.copyWith(
      status: OrderScreenStatus.loaded,
      order: _order,
      restaurant: restaurant,
      deliveryLatitude: _userRepo.address!.latitude,
      deliveryLongitude: _userRepo.address!.longitude,
      deliveryStreet: _userRepo.address!.street,
      deliveryPropertyDetails: _userRepo.address!.propertyDetails,
      restaurantLatitude: restaurant.location.latitude,
      restaurantLongitude: restaurant.location.longitude,
    ));
  }

  getReceipt(bool isStorno) async {
    final url = await _ordersRepo.downloadReceipt(_order, isStorno);
    if (url == null) {
      final status = state.status;
      emit(state.copyWith(
          status: OrderScreenStatus.receiptError));
      Future.delayed(const Duration(seconds: 2), () {
        emit(state.copyWith(status: status));
      });
      return;
    }
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}

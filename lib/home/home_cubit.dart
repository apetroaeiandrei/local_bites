import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/orders_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/restaurant_model.dart';
import 'package:models/user_order.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._userRepo, this._restaurantsRepo, this._ordersRepo)
      : super(const HomeState(
            status: HomeStatus.initial,
            restaurants: [],
            currentOrders: [],
            showCurrentOrder: false)) {
    init();
  }

  final UserRepo _userRepo;
  final RestaurantsRepo _restaurantsRepo;
  final OrdersRepo _ordersRepo;
  StreamSubscription? _currentOrderSubscription;

  init() async {
    if (!await _userRepo.isProfileCompleted()) {
      emit(state.copyWith(status: HomeStatus.profileIncomplete));
      return;
    }

    final address = _userRepo.address;
    if (address == null) {
      emit(state.copyWith(status: HomeStatus.addressError));
      return;
    }

    final success = await _restaurantsRepo.getNearbyRestaurants(
        address.latitude, address.longitude);
    if (success) {
      print(
          'got restaurants successfully ${_restaurantsRepo.restaurants.length}');
      emit(state.copyWith(
        status: HomeStatus.loaded,
        restaurants: _restaurantsRepo.restaurants,
        address: address.street,
      ));
    } else {
      emit(state.copyWith(
        status: HomeStatus.restaurantsError,
      ));
    }

    _currentOrderSubscription = _ordersRepo.currentOrderStream.listen((event) {
      emit(state.copyWith(
          currentOrders: event, showCurrentOrder: event.isNotEmpty));
    });
    _ordersRepo.listenForOrderInProgress();
  }

  @override
  Future<void> close() {
    _currentOrderSubscription?.cancel();
    return super.close();
  }

  void rateOrder(UserOrder currentOrder, bool? liked) {
    _ordersRepo.rateOrder(currentOrder, liked);
  }
}

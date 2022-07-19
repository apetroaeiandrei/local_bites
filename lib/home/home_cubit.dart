import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/restaurant_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._userRepo, this._restaurantsRepo)
      : super(const HomeState(status: HomeStatus.initial, restaurants: [])) {
    init();
  }

  final UserRepo _userRepo;
  final RestaurantsRepo _restaurantsRepo;

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
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:local/repos/user_repo.dart';
import 'package:models/restaurant_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._userRepo, this._restaurantsRepo)
      : super(const HomeState(status: HomeStatus.initial, restaurants: [])) {
    _init();
  }

  final UserRepo _userRepo;
  final RestaurantsRepo _restaurantsRepo;

  _init() async {
    if (await _userRepo.isProfileCompleted()) {
      print('profile completed, getting restaurants');
      final success =
          await _restaurantsRepo.getNearbyRestaurants(47.530534, 25.555038);
      if (success) {
        print('got restaurants successfully ${_restaurantsRepo.restaurants.length}');
        emit(state.copyWith(
          status: HomeStatus.loaded,
          restaurants: _restaurantsRepo.restaurants,
        ));
      } else {
        emit(state.copyWith(
          status: HomeStatus.restaurantsError,
        ));
      }
    } else {
      emit(state.copyWith(status: HomeStatus.profileIncomplete));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:models/restaurant_model.dart';

part 'restaurant_info_state.dart';

class RestaurantInfoCubit extends Cubit<RestaurantInfoState> {
  RestaurantInfoCubit(RestaurantsRepo repo)
      : super(RestaurantInfoState(restaurant: repo.selectedRestaurant));
}

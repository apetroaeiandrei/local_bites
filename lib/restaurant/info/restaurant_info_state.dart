part of 'restaurant_info_cubit.dart';

class RestaurantInfoState extends Equatable {
  final RestaurantModel restaurant;

  @override
  List<Object> get props => [restaurant];

  const RestaurantInfoState({
    required this.restaurant,
  });

  RestaurantInfoState copyWith({
    RestaurantModel? restaurant,
  }) {
    return RestaurantInfoState(
      restaurant: restaurant ?? this.restaurant,
    );
  }
}

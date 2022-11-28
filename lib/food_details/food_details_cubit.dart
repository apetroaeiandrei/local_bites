import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:local/repos/cart_repo.dart';
import 'package:local/repos/restaurants_repo.dart';
import 'package:models/food_model.dart';
import 'package:models/food_option.dart';
import 'package:models/food_option_category.dart';

part 'food_details_state.dart';

class FoodDetailsCubit extends Cubit<FoodDetailsState> {
  FoodDetailsCubit(this._restaurantsRepo, this._cartRepo, FoodModel foodModel)
      : super(FoodDetailsState(
            food: foodModel,
            options: const [],
            selectedOptions: const {},
            invalidOptions: const {},
            price: foodModel.price,
            quantity: 1,
            status: FoodDetailsStatus.initial)) {
    _init();
  }

  final CartRepo _cartRepo;
  final RestaurantsRepo _restaurantsRepo;

  void _init() async {
    final optionCategories =
        await _restaurantsRepo.getFoodOptionsAsync(state.food.optionIds);
    emit(state.copyWith(
      options: optionCategories,
    ));
  }

  void addOption(FoodOption option) {
    final category =
        state.options.firstWhere((element) => element.options.contains(option));
    final selectedCount = category.options
        .where((element) => state.selectedOptions.contains(element.id))
        .length;

    if (selectedCount >= category.maxSelection) {
      return;
    }

    emit(state.copyWith(
      selectedOptions: Set.from(state.selectedOptions)..add(option.id),
      price: state.price + option.price * state.quantity,
      status: FoodDetailsStatus.initial,
    ));
  }

  void removeOption(FoodOption option) {
    emit(state.copyWith(
      selectedOptions: Set.from(state.selectedOptions)..remove(option.id),
      price: state.price - option.price * state.quantity,
      status: FoodDetailsStatus.initial,
    ));
  }

  void addFood() {
    final invalidOptions = _getInvalidOptions();
    if (invalidOptions.isNotEmpty) {
      emit(state.copyWith(
          invalidOptions: invalidOptions,
          status: FoodDetailsStatus.optionsError));
      return;
    }
    Map<String, List<String>> orderSelectedOptions = {};
    for (var element in state.options) {
      for (var option in element.options) {
        if (state.selectedOptions.contains(option.id)) {
          if (orderSelectedOptions[element.name] == null) {
            orderSelectedOptions[element.name] = [];
          }
          orderSelectedOptions[element.name] =
              orderSelectedOptions[element.name]!..add(option.name);
        }
      }
    }
    _cartRepo.addToCart(
        state.food, state.quantity, orderSelectedOptions, state.price);
    emit(state.copyWith(status: FoodDetailsStatus.addSuccess));
  }

  void incrementQuantity() {
    final newPrice = state.price / state.quantity * (state.quantity + 1);
    emit(state.copyWith(quantity: state.quantity + 1, price: newPrice));
  }

  void decrementQuantity() {
    final newPrice = state.price / state.quantity * (state.quantity - 1);
    emit(state.copyWith(quantity: state.quantity - 1, price: newPrice));
  }

  Set<FoodOptionCategory> _getInvalidOptions() {
    final invalidOptions = <FoodOptionCategory>{};
    for (var element in state.options) {
      final selectedCount = element.options
          .where((element) => state.selectedOptions.contains(element.id))
          .length;
      if (selectedCount < element.minSelection) {
        invalidOptions.add(element);
      }
    }
    return invalidOptions;
  }
}

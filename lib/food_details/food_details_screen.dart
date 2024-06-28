import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/food_details/food_details_cubit.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:models/food_option.dart';

import '../analytics/analytics.dart';
import '../analytics/metric.dart';
import '../environment/env.dart';
import '../generated/l10n.dart';
import '../theme/dimens.dart';
import '../utils.dart';

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({super.key});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  final _headerKey = GlobalKey();
  final _scrollController = ScrollController();
  final _analytics = Analytics();
  bool _titleVisible = false;
  bool _nutritionVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final headerPosition = _getHeaderPosition();
      if (headerPosition < 0) {
        if (!_titleVisible) {
          setState(() {
            _titleVisible = true;
          });
        }
      } else {
        if (_titleVisible) {
          setState(() {
            _titleVisible = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FoodDetailsCubit, FoodDetailsState>(
      listener: (context, state) {
        switch (state.status) {
          case FoodDetailsStatus.initial:
            break;
          case FoodDetailsStatus.loading:
            break;
          case FoodDetailsStatus.addSuccess:
            Navigator.of(context).pop();
            break;
          case FoodDetailsStatus.optionsError:
            _showInvalidOptionsSnackBar(context);
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    stretch: true,
                    expandedHeight: Dimens.sliverImageHeight,
                    leadingWidth: 45,
                    leading: Container(
                      margin: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    title: AnimatedOpacity(
                      opacity: _titleVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        state.food.name,
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.network(
                        state.food.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) {
                          return defaultFoodDetailsImage();
                        },
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        key: _headerKey,
                        padding: const EdgeInsets.only(
                            left: Dimens.defaultPadding,
                            top: Dimens.defaultPadding),
                        child: Text(
                          state.food.name,
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: Dimens.defaultPadding,
                          top: Dimens.defaultPadding,
                          right: Dimens.defaultPadding,
                        ),
                        child: Text(
                          state.food.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: Dimens.defaultPadding,
                          top: Dimens.defaultPadding,
                        ),
                        child: Text(
                          S.of(context).price_currency_ron(
                              state.food.discountedPrice > 0
                                  ? state.food.discountedPrice
                                      .toStringAsFixed(1)
                                  : state.food.price,
                              EnvProd.currency),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: state.food.discountedPrice > 0
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                              ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: Dimens.defaultPadding),
                        child: Visibility(
                          visible: state.food.discountedPrice > 0,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Text(
                            S.of(context).price_currency_ron(
                                state.food.price, EnvProd.currency),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                    height: 1,
                                    color: Theme.of(context).disabledColor,
                                    decoration: TextDecoration.lineThrough),
                          ),
                        ),
                      ),
                      ..._getOptions(state),
                      if (state.food.hasNutritionalInfo) _getNutritionButton(),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          height: _nutritionVisible ? null : 0,
                          child: _getNutrition(state),
                        ),
                      ),
                      _getQuantityControls(state),
                      const SizedBox(
                        height: 70,
                      ),
                    ]),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                bottom: state.status == FoodDetailsStatus.loading
                    ? -50
                    : Dimens.defaultPadding,
                left: Dimens.defaultPadding,
                right: Dimens.defaultPadding,
                child: ElevatedButton(
                  onPressed: () {
                    _analytics.logEvent(name: Metric.eventFoodAddToCart);
                    context.read<FoodDetailsCubit>().addFood();
                  },
                  child: Text(
                    S.of(context).food_details_add_button(state.quantity,
                        state.price.toStringAsFixed(1), EnvProd.currency),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Iterable<Widget> _getOptions(FoodDetailsState state) {
    return state.options.map(
      (e) => Padding(
        padding: const EdgeInsets.fromLTRB(Dimens.defaultPadding,
            Dimens.defaultPadding, Dimens.defaultPadding, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              e.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Visibility(
              visible: state.invalidOptions.contains(e),
              child: Text(
                S.of(context).food_details_min_max_error,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WlColors.error,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              S
                  .of(context)
                  .food_details_min_max(e.minSelection, e.maxSelection),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: WlColors.secondary),
            ),
            ...e.options.map((option) => _buildOption(option, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(FoodOption option, FoodDetailsState state) {
    final bool selected = state.selectedOptions.contains(option.id);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            option.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
            S
                .of(context)
                .food_option_price_extra(option.price, EnvProd.currency),
            style: Theme.of(context).textTheme.bodyMedium),
        IconButton(
          visualDensity: VisualDensity.compact,
          splashColor: Theme.of(context).colorScheme.primary,
          splashRadius: 20,
          icon: Icon(selected ? Icons.check_circle : Icons.add),
          onPressed: () {
            if (selected) {
              context.read<FoodDetailsCubit>().removeOption(option);
            } else {
              context.read<FoodDetailsCubit>().addOption(option);
            }
          },
        ),
      ],
    );
  }

  Widget _getQuantityControls(FoodDetailsState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: state.quantity == 1
              ? null
              : () {
                  _analytics.logEvent(name: Metric.eventFoodDecreaseQuantity);
                  context.read<FoodDetailsCubit>().decrementQuantity();
                },
        ),
        Text(
          state.quantity.toString(),
          style: Theme.of(context).textTheme.displayMedium,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            _analytics.logEvent(name: Metric.eventFoodIncreaseQuantity);
            context.read<FoodDetailsCubit>().incrementQuantity();
          },
        ),
      ],
    );
  }

  _showInvalidOptionsSnackBar(BuildContext context) {
    _analytics.logEvent(name: Metric.eventFoodInvalidOptions);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(S.of(context).food_details_invalid_options),
      ),
    );
  }

  double _getHeaderPosition() {
    if (_headerKey.currentContext == null) {
      return 0;
    }
    final RenderBox renderBox =
        _headerKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    return position.dy - MediaQuery.of(context).padding.top - kToolbarHeight;
  }

  Widget _getNutrition(FoodDetailsState state) {
    final food = state.food;
    var allergens = food.allergens ?? "-";
    if (allergens.isEmpty) {
      allergens = "-";
    }
    final style = Theme.of(context).textTheme.bodySmall;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.defaultPadding,
        ),
        child: Text(
          S.of(context).nutrition_portion_size(
              food.portionSize?.toStringAsFixed(0) ?? "-"),
          style: style,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimens.defaultPadding,
        ),
        child: Text(
          S.of(context).nutrition_allergens(allergens),
          style: style,
        ),
      ),
      const SizedBox(
        height: 8,
      ),
      Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.defaultPadding,
                  ),
                  child: Text(
                    S.of(context).nutrition_energy(food.calories ?? "-"),
                    style: style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.defaultPadding,
                  ),
                  child: Text(
                    S.of(context).nutrition_carbohydrates(food.carbs ?? "-"),
                    style: style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.defaultPadding,
                  ),
                  child: Text(
                    S.of(context).nutrition_fat(food.fat ?? "-"),
                    style: style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.defaultPadding,
                  ),
                  child: Text(
                    S
                        .of(context)
                        .nutrition_saturated_fat(food.saturatedFat ?? "-"),
                    style: style,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.defaultPadding,
                  ),
                  child: Text(
                    S.of(context).nutrition_protein(food.protein ?? "-"),
                    style: style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.defaultPadding,
                  ),
                  child: Text(
                    S.of(context).nutrition_sugar(food.sugar ?? "-"),
                    style: style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.defaultPadding,
                  ),
                  child: Text(
                    S.of(context).nutrition_fiber(food.fiber ?? "-"),
                    style: style,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.defaultPadding,
                  ),
                  child: Text(
                    S.of(context).nutrition_salt(food.salt ?? "-"),
                    style: style,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _getNutritionButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _nutritionVisible = !_nutritionVisible;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.defaultPadding,
              vertical: Dimens.defaultPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _nutritionVisible
                      ? S.of(context).food_details_hide_nutrition
                      : S.of(context).food_details_show_nutrition,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    _nutritionVisible
                        ? Icons.arrow_circle_up
                        : Icons.arrow_circle_down,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

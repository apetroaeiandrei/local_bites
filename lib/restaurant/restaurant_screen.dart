import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/restaurant/restaurant_cubit.dart';
import 'package:local/routes.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../analytics/analytics.dart';
import '../generated/l10n.dart';
import '../theme/dimens.dart';
import '../widgets/food_card.dart';
import 'category_content.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final _analytics = Analytics();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemScrollController categoriesItemScrollController =
      ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int _selectedCategoryIndex = 0;
  DateTime? _lastTopCategoryPressTime;

  @override
  void initState() {
    _listenToFoodsPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RestaurantCubit, RestaurantState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.restaurantInfo);
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: ScrollablePositionedList.builder(
                      shrinkWrap: true,
                      itemScrollController: itemScrollController,
                      itemPositionsListener: itemPositionsListener,
                      padding: const EdgeInsets.fromLTRB(
                        Dimens.defaultPadding,
                        0,
                        Dimens.defaultPadding,
                        80,
                      ),
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 30, bottom: 20),
                              child: Text(
                                state.categories[index].category.name
                                    .toUpperCase(),
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ),
                            ...getFoodsInCategory(state.categories[index]),
                          ],
                        );
                      }),
                ),
                Container(
                  height: 50,
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: getPositionsView(state),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  bottom: state.cartCount > 0 ? 30 : -50,
                  left: Dimens.defaultPadding,
                  right: Dimens.defaultPadding,
                  child: ElevatedButton(
                    onPressed: () {
                      _analytics.setCurrentScreen(screenName: Routes.cart);
                      Navigator.of(context)
                          .pushNamed(Routes.cart)
                          .then((value) {
                        _analytics.setCurrentScreen(
                            screenName: Routes.restaurant);
                        context.read<RestaurantCubit>().refreshCart();
                      });
                    },
                    child: Text(
                      S
                          .of(context)
                          .cart_status(state.cartCount, state.cartTotal),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Iterable<Widget> getFoodsInCategory(CategoryContent categoryContent) {
    return categoryContent.foods.map(
      (food) => GestureDetector(
        onTap: food.available
            ? () {
                _analytics.setCurrentScreen(screenName: Routes.foodDetails);
                Navigator.pushNamed(context, Routes.foodDetails,
                        arguments: food)
                    .then((value) {
                  _analytics.setCurrentScreen(screenName: Routes.restaurant);
                  context.read<RestaurantCubit>().refreshCart();
                });
              }
            : null,
        child: FoodCard(
          foodModel: food,
        ),
      ),
    );
  }

  Widget getPositionsView(RestaurantState state) {
    return ScrollablePositionedList.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: state.categories.length,
      itemScrollController: categoriesItemScrollController,
      padding: const EdgeInsets.symmetric(horizontal: Dimens.defaultPadding),
      itemBuilder: (context, index) {
        bool selected = _selectedCategoryIndex == index;
        return InkWell(
          onTap: () {
            _scrollFoodsToIndex(index);
          },
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text(
                state.categories[index].category.name,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: selected
                          ? Theme.of(context).colorScheme.onPrimary
                          : WlColors.placeholderTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }

  _scrollFoodsToIndex(int index) {
    setState(() {
      _lastTopCategoryPressTime = DateTime.now();
      _selectedCategoryIndex = index;
    });
    itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut);
  }

  _scrollCategoriesToIndex(int index) {
    if (_lastTopCategoryPressTime != null &&
        DateTime.now().difference(_lastTopCategoryPressTime!) <
            const Duration(milliseconds: 1000)) {
      return;
    }
    setState(() {
      _selectedCategoryIndex = index;
    });
    categoriesItemScrollController.scrollTo(
        index: index,
        alignment: 0.45,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut);
  }

  void _listenToFoodsPosition() {
    itemPositionsListener.itemPositions.addListener(() {
      int min = 0;
      if (itemPositionsListener.itemPositions.value.isNotEmpty) {
        // Determine the first visible item by finding the item with the
        // smallest trailing edge that is greater than 0.  i.e. the first
        // item whose trailing edge in visible in the viewport.
        min = itemPositionsListener.itemPositions.value
            .where((ItemPosition position) => position.itemTrailingEdge > 0)
            .reduce((ItemPosition min, ItemPosition position) =>
                position.itemTrailingEdge < min.itemTrailingEdge
                    ? position
                    : min)
            .index;
      }
      if (min != _selectedCategoryIndex) {
        _scrollCategoriesToIndex(min);
      }
    });
  }
}

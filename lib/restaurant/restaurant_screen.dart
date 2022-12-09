import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/restaurant/restaurant_cubit.dart';
import 'package:local/routes.dart';

import '../analytics/analytics.dart';
import '../generated/l10n.dart';
import '../theme/dimens.dart';
import '../widgets/food_card.dart';
import 'category_content.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final _analytics = Analytics();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RestaurantCubit, RestaurantState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.name),
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      Dimens.defaultPadding,
                      Dimens.defaultPadding,
                      Dimens.defaultPadding,
                      80,
                    ),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 30, bottom: 20),
                            child: Text(
                              state.categories[index].category.name
                                  .toUpperCase(),
                              style: Theme.of(context).textTheme.headline3,
                            ),
                          ),
                          ...getFoodsInCategory(state.categories[index]),
                        ],
                      );
                    }),
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
        onTap: () {
          _analytics.setCurrentScreen(screenName: Routes.foodDetails);
          Navigator.pushNamed(context, Routes.foodDetails, arguments: food)
              .then((value) {
            _analytics.setCurrentScreen(screenName: Routes.restaurant);
            context.read<RestaurantCubit>().refreshCart();
          });
        },
        child: FoodCard(
          foodModel: food,
        ),
      ),
    );
  }
}

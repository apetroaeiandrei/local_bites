import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/restaurant/restaurant_cubit.dart';
import 'package:local/routes.dart';

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
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: Dimens.defaultPadding),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 30, left: 10),
                              child: Text(
                                state.categories[index].category.name,
                                style: Theme.of(context).textTheme.headline2,
                              ),
                            ),
                            ...getFoodsInCategory(state.categories[index]),
                          ],
                        );
                      }),
                  Positioned(
                    bottom: Dimens.defaultPadding,
                    left: Dimens.defaultPadding,
                    right: Dimens.defaultPadding,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.cart);
                      },
                      child: Text(
                        S
                            .of(context)
                            .cart_status(state.cartCount, state.cartTotal),
                      ),
                    ),
                  ),
                ],
              ));
        });
  }

  Iterable<Widget> getFoodsInCategory(CategoryContent categoryContent) {
    return categoryContent.foods.map(
      (food) => GestureDetector(
        onTap: () {
          if (food.hasOptions) {
            Navigator.pushNamed(context, Routes.foodDetails, arguments: food);
          } else {
            context.read<RestaurantCubit>().addToCart(food);
          }
        },
        child: FoodCard(
          foodModel: food,
        ),
      ),
    );
  }
}

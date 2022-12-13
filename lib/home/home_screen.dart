import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/home/home_cubit.dart';
import 'package:local/widgets/dialog_utils.dart';
import 'package:local/widgets/order_mini.dart';
import 'package:models/restaurant_model.dart';

import '../analytics/analytics.dart';
import '../analytics/metric.dart';
import '../generated/l10n.dart';
import '../img.dart';
import '../routes.dart';
import '../theme/dimens.dart';
import '../widgets/home_screen_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _orderMiniHeight = 200.0;
  final _analytics = Analytics();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (BuildContext context, HomeState state) {
        switch (state.status) {
          case HomeStatus.profileIncomplete:
            _showProfileScreen(context);
            break;
          case HomeStatus.initial:
            break;
          case HomeStatus.loaded:
            break;
          case HomeStatus.loading:
            // TODO: Handle this case.
            break;
          case HomeStatus.restaurantsError:
            // TODO: Handle this case.
            break;
          case HomeStatus.error:
            // TODO: Handle this case.
            break;
          case HomeStatus.addressError:
            _showAddressScreen(context);
            break;
        }
      },
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).home_welcome),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.settings).then(
                      (value) =>
                          _analytics.setCurrentScreen(screenName: Routes.home));
                },
              ),
            ],
          ),
          bottomSheet: !state.showCurrentOrder
              ? null
              : Container(
                  width: double.infinity,
                  height: _orderMiniHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        spreadRadius: 0,
                        blurRadius: 4,
                        offset:
                            const Offset(0, -4), // changes position of shadow
                      ),
                    ],
                  ),
                  child: CarouselSlider.builder(
                    options: CarouselOptions(
                      height: _orderMiniHeight,
                      viewportFraction: 1,
                      enableInfiniteScroll: state.currentOrders.length > 1,
                      autoPlay: state.currentOrders.length > 1,
                      autoPlayInterval: const Duration(seconds: 8),
                      initialPage: 0,
                    ),
                    itemCount: state.currentOrders.length,
                    itemBuilder:
                        (BuildContext context, int index, int realIndex) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _analytics.setCurrentScreen(
                              screenName: Routes.orderDetails);
                          Navigator.of(context)
                              .pushNamed(Routes.orderDetails,
                                  arguments: state.currentOrders[index])
                              .then((value) => _analytics.setCurrentScreen(
                                  screenName: Routes.home));
                        },
                        child: OrderMini(
                          order: state.currentOrders[index],
                          onFeedback: (liked) {
                            context
                                .read<HomeCubit>()
                                .rateOrder(state.currentOrders[index], liked);
                          },
                        ),
                      );
                    },
                  ),
                ),
          body: state.restaurants.isEmpty
              ? _getEmptyRestaurants(state)
              : ListView.builder(
                  itemCount: state.restaurants.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _getAddressZone(context, state);
                    } else {
                      return _getRestaurantCard(context, state, index - 1);
                    }
                  }),
        );
      },
    );
  }

  Widget _getEmptyRestaurants(HomeState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _getAddressZone(context, state),
          Image.asset(Img.emptyPlate),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              S.of(context).home_restaurants_empty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline4,
            ),
          )
        ],
      ),
    );
  }

  Widget _getAddressZone(BuildContext context, HomeState state) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.defaultPadding),
      child: GestureDetector(
        onTap: () {
          _showAddressScreen(context);
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.address ?? S.of(context).home_address_empty,
                style: Theme.of(context).textTheme.headline5,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getRestaurantCard(BuildContext context, HomeState state, int i) {
    final restaurant = state.restaurants[i];
    return GestureDetector(
      onTap: () {
        if (context
            .read<HomeCubit>()
            .hasCartOnDifferentRestaurant(restaurant.id)) {
          _showExistingCartDialog(context.read<HomeCubit>(), restaurant);
        } else {
          context.read<HomeCubit>().setRestaurantId(restaurant.id);
          Navigator.of(context)
              .pushNamed(Routes.restaurant, arguments: restaurant)
              .then((value) =>
                  _analytics.setCurrentScreen(screenName: Routes.home));
        }
      },
      child: HomeScreenCard(
        restaurant: restaurant,
      ),
    );
  }

  _showExistingCartDialog(HomeCubit cubit, RestaurantModel restaurant) {
    final List<Widget> actions = [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _analytics.logEvent(name: Metric.eventProductsInCartDialogCancel);
        },
        child: Text(S.of(context).home_cart_different_restaurant_cancel),
      ),
      TextButton(
        onPressed: () {
          cubit.setRestaurantId(restaurant.id);
          Navigator.of(context).pop();
          _analytics.logEvent(name: Metric.eventProductsInCartDialogConfirm);
          Navigator.of(context)
              .pushNamed(Routes.restaurant, arguments: restaurant)
              .then((value) =>
                  _analytics.setCurrentScreen(screenName: Routes.home));
        },
        child: Text(S.of(context).home_cart_different_restaurant_ok),
      ),
    ];

    showPlatformDialog(
      context: context,
      title: S.of(context).home_cart_different_restaurant_title,
      content: S.of(context).home_cart_different_restaurant_content,
      actions: actions,
    );
  }

  void _showProfileScreen(BuildContext context) {
    Navigator.of(context)
        .pushNamed(Routes.profile)
        .then((value) => context.read<HomeCubit>().init());
  }

  void _showAddressScreen(BuildContext context) {
    Navigator.of(context)
        .pushNamed(Routes.address)
        .then((value) => context.read<HomeCubit>().init());
  }
}

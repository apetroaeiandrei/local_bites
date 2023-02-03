import 'package:app_settings/app_settings.dart';
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const _orderMiniHeight = 200.0;
  final _analytics = Analytics();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<HomeCubit>().onAppLifecycleStateChanged(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
          case HomeStatus.showSettingsNotification:
            _showNotificationSettingsDialog();
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
                  shrinkWrap: true,
                  itemCount: state.restaurants.length +
                      (state.showNotificationsPrompt ? 2 : 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _getAddressZone(context, state);
                    } else if (index == 1) {
                      return _getRestaurantCard(context, state, index - 1);
                    } else if (index == 2 && state.showNotificationsPrompt) {
                      return _getNotificationsBanner();
                    } else {
                      return _getRestaurantCard(context, state,
                          index - (state.showNotificationsPrompt ? 2 : 1));
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
              style: Theme.of(context).textTheme.headlineMedium,
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
                style: Theme.of(context).textTheme.headlineSmall,
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
          _analytics.logEventWithParams(
              name: Metric.eventRestaurantsEnter,
              parameters: {
                Metric.propertyRestaurantsName: restaurant.name,
              });
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
          _analytics.logEventWithParams(
              name: Metric.eventRestaurantsEnter,
              parameters: {
                Metric.propertyRestaurantsName: restaurant.name,
              });

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

  Widget _getNotificationsBanner() {
    return InkWell(
      onTap: () {
        context.read<HomeCubit>().onWantNotificationsClick();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.cardCornerRadius),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Center(
          child: Text(
            S.of(context).home_notifications_banner,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
        ),
      ),
    );
  }

  _showNotificationSettingsDialog() {
    final List<Widget> actions = [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _analytics.logEvent(name: Metric.eventNotificationsDialogCancel);
        },
        child: Text(S.of(context).home_notifications_dialog_cancel),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _analytics.logEvent(name: Metric.eventNotificationsDialogConfirm);
          AppSettings.openNotificationSettings();
        },
        child: Text(S.of(context).home_notifications_dialog_ok),
      ),
    ];

    showPlatformDialog(
      context: context,
      title: S.of(context).home_notifications_dialog_title,
      content: S.of(context).home_notifications_dialog_content,
      actions: actions,
    );
  }
}

import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/address/address_type_extension.dart';
import 'package:local/feedback/feedback_cubit.dart';
import 'package:local/home/home_address_tile.dart';
import 'package:local/home/home_cubit.dart';
import 'package:local/repos/user_repo.dart';
import 'package:local/utils.dart';
import 'package:local/widgets/dialog_utils.dart';
import 'package:local/widgets/order_mini.dart';
import 'package:models/delivery_address.dart';
import 'package:models/restaurant_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/analytics.dart';
import '../analytics/metric.dart';
import '../environment/app_config.dart';
import '../feedback/feedback_screen.dart';
import '../generated/l10n.dart';
import '../img.dart';
import '../routes.dart';
import '../theme/dimens.dart';
import '../widgets/home_screen_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const prefKeyVouchersSeen = 'vouchersSeen';
  final _analytics = Analytics();
  Color _vouchersIconColor = Colors.black;
  Timer? _vouchersFlashTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _flashVouchersIcon();
    _checkAppVersion();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<HomeCubit>().onAppLifecycleStateChanged(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vouchersFlashTimer?.cancel();
    super.dispose();
  }

  _flashVouchersIcon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(prefKeyVouchersSeen)) {
      _vouchersFlashTimer =
          Timer.periodic(const Duration(milliseconds: 400), (timer) {
        setState(() {
          if (_vouchersIconColor == Colors.black) {
            _vouchersIconColor = Theme.of(context).colorScheme.primary;
          } else {
            _vouchersIconColor = Colors.black;
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (BuildContext context, HomeState state) {
        if (state.showCurrentOrder) {
          _showCurrentOrdersBottomSheet(context, state);
        }
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
          case HomeStatus.showKnownNearestAddressDialog:
            _showKnownAddressDialog(context, state.nearestDeliveryAddress!);
            break;
          case HomeStatus.showUnknownNearestAddressDialog:
            _showUnknownAddressDialog(context);
            break;
          case HomeStatus.showLocationPermissionDialog:
            _showLocationPermissionDialog(context);
            break;
        }
      },
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).home_welcome),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.local_offer_outlined,
                  color: _vouchersIconColor,
                ),
                onPressed: () async {
                  _analytics.setCurrentScreen(screenName: Routes.vouchers);
                  Navigator.of(context).pushNamed(Routes.vouchers).then(
                      (value) =>
                          _analytics.setCurrentScreen(screenName: Routes.home));
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool(prefKeyVouchersSeen, true);
                  _vouchersFlashTimer?.cancel();
                  setState(() {
                    _vouchersIconColor = Colors.black;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  _analytics.setCurrentScreen(screenName: Routes.help);
                  Navigator.of(context).pushNamed(Routes.help).then((value) =>
                      _analytics.setCurrentScreen(screenName: Routes.home));
                },
              ),
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
          bottomSheet: state.showCurrentOrder && !_bottomSheetShown
              ? GestureDetector(
                  onTapDown: (_) {
                    _showCurrentOrdersBottomSheet(context, state);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            height: 4,
                            width: 30,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.4),
                            ),
                          ),
                        ),
                        _getMiniBottomSheetContent(state),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom,
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          body: _getContent(state),
        );
      },
    );
  }

  Widget _getContent(HomeState state) {
    if (state.status == HomeStatus.loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 100),
              child: Text(S.of(context).home_loading_restaurants,
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
          ],
        ),
      );
    }
    final listWidgets = _buildHomeScreenWidgetList(state);
    return state.restaurants.isEmpty || state.isNoGoZone
        ? _getEmptyRestaurants(state)
        : ListView.builder(
            shrinkWrap: true,
            itemCount: listWidgets.length,
            itemBuilder: (context, index) {
              return listWidgets[index];
            });
  }

  List<Widget> _buildHomeScreenWidgetList(HomeState state) {
    final List<Widget> widgets = [];
    if (state.restaurants.isEmpty) {
      return widgets;
    }
    bool hasGroceryZone = false;
    widgets.add(_getAddressZone(context, state));
    for (int i = 0; i < state.restaurants.length; i++) {
      final restaurant = state.restaurants[i];
      // Assume grocery restaurants are sorted at the end of the list
      if (restaurant.isGrocery) {
        if (!hasGroceryZone) {
          hasGroceryZone = true;
          widgets.add(_getGroceryZone());
        }
      }
      widgets.add(_getRestaurantCard(context, restaurant));
    }
    if (state.showNotificationsPrompt) {
      widgets.insert(2, _getNotificationsBanner());
    }
    return widgets;
  }

  Widget _getGroceryZone() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 40, 16, 10),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.2),
        border: Border.all(
          color: theme.colorScheme.secondary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          S.of(context).home_grocery_headline,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
      ),
    );
  }

  void _showFeedbackScreen(HomeState state, int index) {
    _analytics.setCurrentScreen(screenName: Routes.feedback);
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => BlocProvider<FeedbackCubit>(
          create: (context) => FeedbackCubit(
            RepositoryProvider.of<Analytics>(context),
            RepositoryProvider.of<UserRepo>(context),
            state.currentOrders[index],
          ),
          child: const FeedbackScreen(),
        ),
      ),
    )
        .then((value) {
      _analytics.setCurrentScreen(screenName: Routes.home);
      //hide bottom sheet
      Navigator.of(context).pop();
      setState(() {
        _bottomSheetShown = false;
      });
    });
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
    if (state.address == null) {
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
                  S.of(context).home_address_empty,
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
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimens.defaultPadding, 10, Dimens.defaultPadding, 0),
        child: GestureDetector(
          onTap: () {
            _showAddressScreen(context);
          },
          child: HomeAddressTile(
            address: state.address!,
          ),
        ),
      );
    }
  }

  Widget _getRestaurantCard(
    BuildContext context,
    RestaurantModel restaurant,
  ) {
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
        .pushNamed(Routes.profile, arguments: true)
        .then((value) => context.read<HomeCubit>().init());
  }

  void _showAddressScreen(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.addresses).then((value) {
      context.read<HomeCubit>().init();
    });
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
          AppSettings.openAppSettings(type: AppSettingsType.notification);
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

  _checkAppVersion() async {
    final versionMessage = await AppConfig.checkAppVersion();
    if (versionMessage != null) {
      _analytics.logEvent(name: Metric.eventAppVersionDialog);
      showAppVersionDialog(context: context, message: versionMessage);
    }
  }

  void _showKnownAddressDialog(BuildContext context, DeliveryAddress address) {
    final List<Widget> actions = [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _analytics.logEvent(name: Metric.eventKnownAddressDialogCancel);
        },
        child: Text(S.of(context).home_address_dialog_cancel),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _analytics.logEvent(name: Metric.eventKnownAddressDialogConfirm);
          context.read<HomeCubit>().setDeliveryAddress(address);
        },
        child: Text(S.of(context).home_known_address_dialog_ok),
      ),
    ];
    showPlatformDialog(
        context: context,
        title: S.of(context).home_address_dialog_title,
        content: S.of(context).home_known_address_dialog_content(
              address.addressType.getName(context),
              address.street,
            ),
        actions: actions);
  }

  void _showUnknownAddressDialog(BuildContext context) {
    final List<Widget> actions = [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _analytics.logEvent(name: Metric.eventUnknownAddressDialogCancel);
        },
        child: Text(S.of(context).home_address_dialog_cancel),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _analytics.logEvent(name: Metric.eventUnknownAddressDialogConfirm);
          _showAddressScreen(context);
        },
        child: Text(S.of(context).home_unknown_address_dialog_ok),
      ),
    ];
    showPlatformDialog(
        context: context,
        title: S.of(context).home_address_dialog_title,
        content: S.of(context).home_unknown_address_dialog_content,
        actions: actions);
  }

  void _showLocationPermissionDialog(BuildContext context) {
    final List<Widget> actions = [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _analytics.logEvent(
              name: Metric.eventHomeLocationPermissionDialogCancel);
        },
        child: Text(S.of(context).home_location_permission_dialog_cancel),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          _analytics.logEvent(
              name: Metric.eventHomeLocationPermissionDialogConfirm);
          AppSettings.openAppSettings(type: AppSettingsType.location);
        },
        child: Text(S.of(context).home_location_permission_dialog_ok),
      ),
    ];
    showPlatformDialog(
        context: context,
        title: S.of(context).home_location_permission_dialog_title,
        content: S.of(context).home_location_permission_dialog_content,
        actions: actions);
  }

  bool _bottomSheetShown = false;
  ValueNotifier<HomeState>? _bottomSheetStateNotifier;

  _showCurrentOrdersBottomSheet(BuildContext parentContext, HomeState state) {
    if (_bottomSheetShown) {
      _bottomSheetStateNotifier!.value = state;
      return;
    }
    _bottomSheetStateNotifier = ValueNotifier(state);
    _bottomSheetShown = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      showModalBottomSheet(
        useRootNavigator: true,
        context: parentContext,
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) => ValueListenableBuilder<HomeState>(
            valueListenable: _bottomSheetStateNotifier!,
            builder: (context, state, child) {
              return CarouselSlider.builder(
                options: CarouselOptions(
                  viewportFraction: 1,
                  enableInfiniteScroll: state.currentOrders.length > 1,
                  autoPlay: state.currentOrders.length > 1,
                  autoPlayInterval: const Duration(seconds: 8),
                  initialPage: 0,
                ),
                itemCount: state.currentOrders.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _analytics.setCurrentScreen(
                          screenName: Routes.orderDetails);
                      Navigator.of(parentContext)
                          .pushNamed(Routes.orderDetails,
                              arguments: state.currentOrders[index])
                          .then((value) => _analytics.setCurrentScreen(
                              screenName: Routes.home));
                    },
                    child: OrderMini(
                      order: state.currentOrders[index],
                      onFeedback: (showFeedback) {
                        if (showFeedback) {
                          _showFeedbackScreen(state, index);
                        }
                        parentContext
                            .read<HomeCubit>()
                            .rateOrder(state.currentOrders[index]);
                      },
                      onOrderCancelled: (order) {
                        parentContext.read<HomeCubit>().cancelOrder(order);
                      },
                    ),
                  );
                },
              );
            }),
        enableDrag: true,
        shape: _getBottomSheetShape(),
      ).then((value) {
        setState(() {
          _bottomSheetShown = false;
        });
      });
    });
  }

  ShapeBorder _getBottomSheetShape() {
    return const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    );
  }

  _getMiniBottomSheetContent(HomeState state) {
    return StatefulBuilder(builder: (context, setState) {
      return CarouselSlider.builder(
        options: CarouselOptions(
          height: 30,
          viewportFraction: 1,
          enableInfiniteScroll: state.currentOrders.length > 1,
          autoPlay: state.currentOrders.length > 1,
          autoPlayInterval: const Duration(seconds: 8),
          initialPage: 0,
        ),
        itemCount: state.currentOrders.length,
        itemBuilder: (BuildContext context, int index, int realIndex) {
          final restaurantName = state.currentOrders[index].restaurantName;
          final orderStatus =
              state.currentOrders[index].status.toUserString(context);
          return Text(
            "$restaurantName - $orderStatus",
            style: Theme.of(context).textTheme.headlineSmall,
          );
        },
      );
    });
  }
}

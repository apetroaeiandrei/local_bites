import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/restaurant/info/restaurant_info_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../analytics/analytics.dart';
import '../../analytics/metric.dart';
import '../../generated/l10n.dart';
import '../../theme/dimens.dart';
import '../../utils.dart';

class RestaurantInfoScreen extends StatefulWidget {
  const RestaurantInfoScreen({Key? key}) : super(key: key);

  @override
  State<RestaurantInfoScreen> createState() => _RestaurantInfoScreenState();
}

class _RestaurantInfoScreenState extends State<RestaurantInfoScreen> {
  final _headerKey = GlobalKey();
  final _scrollController = ScrollController();
  final _analytics = Analytics();
  bool _titleVisible = false;

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
    return BlocBuilder<RestaurantInfoCubit, RestaurantInfoState>(
      builder: (context, state) {
        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
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
                    state.restaurant.name,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    state.restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return defaultRestaurantImage();
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      key: _headerKey,
                      padding: const EdgeInsets.all(Dimens.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.restaurant.name,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            state.restaurant.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(Dimens.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).restaurant_info_address,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            state.restaurant.address,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(Dimens.defaultPadding),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).restaurant_info_phone,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                state.restaurant.phone,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _analytics.logEvent(
                                name: Metric.eventRestaurantInfoCall,
                              );
                              Utils.launchCall(state.restaurant.phone);
                            },
                            icon: const Icon(Icons.phone),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(Dimens.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).restaurant_info_email,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            state.restaurant.email,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: state.restaurant.website.isNotEmpty,
                      child: const Divider(),
                    ),
                    Visibility(
                      visible: state.restaurant.website.isNotEmpty,
                      child: Container(
                        padding: const EdgeInsets.all(Dimens.defaultPadding),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).restaurant_info_website,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    state.restaurant.website,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: Dimens.defaultPadding,
                            ),
                            IconButton(
                              onPressed: () {
                                _analytics.logEvent(
                                  name: Metric.eventRestaurantInfoCall,
                                );
                                launchUrl(Uri.parse(state.restaurant.website));
                              },
                              icon: const Icon(Icons.open_in_browser),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Container(
                      padding: const EdgeInsets.all(Dimens.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).restaurant_info_services,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Visibility(
                            visible: state.restaurant.hasDelivery,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Text(
                                  S.of(context).cart_delivery_headline,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(_getDeliveryPaymentInfo(state),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          Visibility(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  S.of(context).cart_pickup_headline,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(_getPickupPaymentInfo(state),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _getHeaderPosition() {
    final RenderBox renderBox =
        _headerKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    return position.dy - MediaQuery.of(context).padding.top - kToolbarHeight;
  }

  String _getDeliveryPaymentInfo(RestaurantInfoState state) {
    final restaurant = state.restaurant;
    if (restaurant.hasDeliveryCash && restaurant.hasDeliveryCard) {
      return S.of(context).cart_pay_delivery_cash_and_card;
    } else if (restaurant.hasDeliveryCash) {
      return S.of(context).cart_pay_delivery_cash;
    } else {
      return S.of(context).cart_pay_delivery_card;
    }
  }

  String _getPickupPaymentInfo(RestaurantInfoState state) {
    final restaurant = state.restaurant;
    if (restaurant.hasPickupCash && restaurant.hasPickupCard) {
      return S.of(context).cart_pay_pickup_cash_and_card;
    } else if (restaurant.hasPickupCash) {
      return S.of(context).cart_pay_pickup_cash;
    } else {
      return S.of(context).cart_pay_pickup_card;
    }
  }
}

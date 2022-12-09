import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/analytics/metric.dart';
import 'package:local/cart/cart_cubit.dart';
import 'package:local/routes.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:local/widgets/dialog_utils.dart';

import '../analytics/analytics.dart';
import '../generated/l10n.dart';
import '../img.dart';
import '../theme/dimens.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const _mapHeight = 150.0;
  static const _pinTopDistance = _mapHeight / 2 - Dimens.locationPinHeight;
  final _analytics = Analytics();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state.status == CartStatus.orderSuccess) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state.status == CartStatus.restaurantClosed) {
          _analytics.logEvent(name: Metric.eventCartRestaurantClosed);
          _showRestaurantClosedDialog(context);
        } else if (state.status == CartStatus.minimumOrderError) {
          _analytics.logEvent(name: Metric.eventCartMinOrder);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).cart_title),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Dimens.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(S.of(context).cart_order_headline,
                          style: Theme.of(context).textTheme.headline2),
                      Text(
                          S.of(context).cart_order_summary(
                              state.cartCount, state.restaurantName),
                          style: Theme.of(context).textTheme.bodyText2),
                      const SizedBox(height: 32),
                      ...state.cartItems.map((item) {
                        return CartItem(
                          item: item,
                          showAddRemoveButtons: true,
                          onAdd: () {
                            _analytics.logEvent(
                                name: Metric.eventCartIncreaseQuantity);
                            context.read<CartCubit>().add(item);
                          },
                          onRemove: () {
                            _analytics.logEvent(
                                name: Metric.eventCartDecreaseQuantity);
                            context.read<CartCubit>().remove(item);
                          },
                        );
                      }),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () {
                          _analytics.setCurrentScreen(
                              screenName: Routes.mentions);
                          Navigator.of(context)
                              .pushNamed(Routes.mentions,
                                  arguments: state.mentions)
                              .then((value) {
                            _analytics.setCurrentScreen(
                                screenName: Routes.cart);
                            context
                                .read<CartCubit>()
                                .updateMentions(value as String?);
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).cart_mentions,
                                style: Theme.of(context).textTheme.headline3),
                            const Icon(
                              Icons.arrow_forward_ios,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4.0,
                          right: 50,
                        ),
                        child: Text(state.mentions,
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      const SizedBox(height: 12),
                      Text(S.of(context).cart_delivery_headline,
                          style: Theme.of(context).textTheme.headline3),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        height: _mapHeight,
                        child: Stack(
                          children: [
                            GoogleMap(
                              myLocationButtonEnabled: false,
                              myLocationEnabled: false,
                              mapType: MapType.normal,
                              onMapCreated: (GoogleMapController controller) {},
                              initialCameraPosition: CameraPosition(
                                target: LatLng(state.deliveryLatitude,
                                    state.deliveryLongitude),
                                zoom: 15,
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              top: _pinTopDistance,
                              child: Image.asset(
                                Img.locationPin,
                                height: Dimens.locationPinHeight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(state.deliveryStreet,
                          style: Theme.of(context).textTheme.headline5),
                      const SizedBox(height: 8),
                      Text(state.deliveryPropertyDetails,
                          style: Theme.of(context).textTheme.bodyText2),
                      Container(
                        height: 1,
                        color: WlColors.onSurface,
                        margin: const EdgeInsets.fromLTRB(0, 40, 0, 20),
                      ),
                      Text(S.of(context).cart_summary,
                          style: Theme.of(context).textTheme.headline3),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).cart_products,
                              style: Theme.of(context).textTheme.subtitle1),
                          Text(
                              S.of(context).price_currency_ron(state.cartTotal),
                              style: Theme.of(context).textTheme.subtitle1),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).cart_delivery_fee,
                              style: Theme.of(context).textTheme.subtitle1),
                          Text(S.of(context).cart_delivery_fee_free,
                              style: Theme.of(context).textTheme.subtitle1),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).cart_total.toUpperCase(),
                              style: Theme.of(context).textTheme.headline4),
                          Text(
                              S.of(context).price_currency_ron(state.cartTotal),
                              style: Theme.of(context).textTheme.headline4),
                        ],
                      ),
                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: Dimens.defaultPadding,
                right: Dimens.defaultPadding,
                child: ElevatedButton(
                  onPressed: state.status == CartStatus.minimumOrderError
                      ? null
                      : () {
                          _analytics.logEventWithParams(
                              name: Metric.eventCartPlaceOrder,
                              parameters: {
                                Metric.propertyOrderPrice: state.cartTotal,
                              });
                          context.read<CartCubit>().checkout();
                        },
                  child: Text(state.status == CartStatus.minimumOrderError
                      ? S.of(context).cart_button_min_order(state.minOrder)
                      : S.of(context).cart_confirm_button),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRestaurantClosedDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      title: S.of(context).cart_restaurant_closed_title,
      content: S.of(context).cart_restaurant_closed_content,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).cart_restaurant_closed_ok),
        ),
      ],
    );
  }
}

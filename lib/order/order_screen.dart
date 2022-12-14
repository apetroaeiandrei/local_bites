import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/order/order_cubit.dart';
import 'package:local/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:models/order_status.dart';

import '../analytics/analytics.dart';
import '../analytics/metric.dart';
import '../generated/l10n.dart';
import '../img.dart';
import '../routes.dart';
import '../theme/dimens.dart';
import '../theme/wl_colors.dart';
import '../widgets/cart_item.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  static const _mapHeight = 150.0;
  static const _pinTopDistance = _mapHeight / 2 - Dimens.locationPinHeight;
  final _analytics = Analytics();

  final _pickupKey = GlobalKey();
  final _deliveryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).order_details_title),
          ),
          body: state.status == OrderScreenStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimens.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(state.restaurant!.name,
                                  style: Theme.of(context).textTheme.headline2),
                            ),
                            IconButton(
                                onPressed: () {
                                  _analytics.logEventWithParams(
                                      name: Metric.eventOrderDetailsCall,
                                      parameters: {
                                        Metric.propertyOrderCallStatus:
                                            state.order!.status.toSimpleString()
                                      });
                                  Utils.launchCall(state.restaurant!.phone);
                                },
                                icon: const Icon(Icons.phone)),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        GestureDetector(
                          onTap: () {
                            _analytics.setCurrentScreen(
                                screenName: Routes.restaurant);
                            Navigator.of(context)
                                .pushNamed(
                                  Routes.restaurant,
                                  arguments: state.restaurant,
                                )
                                .then((value) => _analytics.setCurrentScreen(
                                    screenName: Routes.orderDetails));
                          },
                          child: Text(
                            S.of(context).order_details_restaurant_see_menu,
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(color: WlColors.primary),
                          ),
                        ),
                        Row(
                          children: [
                            Lottie.asset(
                              state.order!.status.toLottieResource(),
                              repeat:
                                  state.order!.status != OrderStatus.completed,
                              width: 130,
                              height: 130,
                            ),
                            Expanded(
                              child: Text(
                                state.order!.status.toUserString(context),
                                style: Theme.of(context)
                                    .textTheme
                                    .headline2
                                    ?.copyWith(
                                      color: state.order!.status.toTextColor(),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ...state.order!.foods.map((item) {
                          return CartItem(item: item);
                        }),
                        const SizedBox(height: 4),
                        Visibility(
                          visible: state.order!.mentions.isNotEmpty,
                          child: Text(S.of(context).cart_mentions,
                              style: Theme.of(context).textTheme.headline3),
                        ),
                        Visibility(
                          visible: state.order!.mentions.isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                              right: 50,
                              bottom: Dimens.defaultPadding,
                            ),
                            child: Text(state.order!.mentions,
                                style: Theme.of(context).textTheme.bodyText2),
                          ),
                        ),
                        _getConfiguration(state),
                        Container(
                          height: 1,
                          color: WlColors.onSurface,
                          margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
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
                                S.of(context).price_currency_ron(
                                    state.order!.totalProducts),
                                style: Theme.of(context).textTheme.subtitle1),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Visibility(
                          visible: state.order!.isDelivery,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(S.of(context).cart_delivery_fee,
                                  style: Theme.of(context).textTheme.subtitle1),
                              Text(
                                  state.order!.deliveryFee > 0
                                      ? S
                                          .of(context)
                                          .cart_delivery_fee_currency(state
                                              .order!.deliveryFee
                                              .toStringAsFixed(1))
                                      : S.of(context).cart_delivery_fee_free,
                                  style: Theme.of(context).textTheme.subtitle1),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).cart_total.toUpperCase(),
                                style: Theme.of(context).textTheme.headline4),
                            Text(
                                S
                                    .of(context)
                                    .price_currency_ron(state.order!.total),
                                style: Theme.of(context).textTheme.headline4),
                          ],
                        ),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _getConfiguration(OrderState state) {
    if (state.order!.isDelivery) {
      return _getDeliveryConfigurationWidget(state);
    } else {
      return _getPickupConfigurationWidget(state);
    }
  }

  Widget _getDeliveryConfigurationWidget(OrderState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(S.of(context).cart_delivery_headline,
            style: Theme.of(context).textTheme.headline3),
        const SizedBox(height: 4),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: _mapHeight,
          child: Stack(
            children: [
              GoogleMap(
                key: _deliveryKey,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {},
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(state.deliveryLatitude, state.deliveryLongitude),
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
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _getPickupConfigurationWidget(OrderState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(S.of(context).cart_pickup_headline,
            style: Theme.of(context).textTheme.headline3),
        const SizedBox(
          height: 4,
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          height: _mapHeight,
          child: Stack(
            children: [
              GoogleMap(
                key: _pickupKey,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                mapType: MapType.normal,
                onMapCreated: (GoogleMapController controller) {},
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      state.restaurantLatitude, state.restaurantLongitude),
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
        Text(state.restaurantAddress,
            style: Theme.of(context).textTheme.headline5),
        const SizedBox(height: 8),
      ],
    );
  }
}

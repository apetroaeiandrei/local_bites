import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/order/order_cubit.dart';
import 'package:local/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:models/order_status.dart';

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
                            Navigator.of(context).pushNamed(
                              Routes.restaurant,
                              arguments: state.restaurant,
                            );
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
                              repeat: state.order!.status != OrderStatus.completed,
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
                        Text(S.of(context).cart_mentions,
                            style: Theme.of(context).textTheme.headline3),
                        // Text(state.order!.mentions,
                        //     style: Theme.of(context).textTheme.bodyText2),
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
                                onMapCreated: (GoogleMapController controller) {
                                  //_controller.complete(controller);
                                },
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(state.order!.latitude,
                                      state.order!.longitude),
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
                        Text(state.order!.street,
                            style: Theme.of(context).textTheme.headline5),
                        const SizedBox(height: 8),
                        Text(state.order!.propertyDetails,
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
                                S
                                    .of(context)
                                    .price_currency_ron(state.order!.total),
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
}

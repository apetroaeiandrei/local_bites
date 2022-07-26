import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/cart/cart_cubit.dart';
import 'package:local/theme/wl_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        // TODO: implement listener
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
                        return CartItem(item: item);
                      }),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).cart_mentions,
                              style: Theme.of(context).textTheme.headline3),
                          const Icon(
                            Icons.arrow_forward_ios,
                          ),
                        ],
                      ),
                      Text(state.mentions,
                          style: Theme.of(context).textTheme.bodyText2),
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
                  onPressed: () {
                    context.read<CartCubit>().checkout();
                  },
                  child: Text(S.of(context).cart_confirm_button),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

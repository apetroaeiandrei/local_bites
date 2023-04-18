import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:local/analytics/metric.dart';
import 'package:local/cart/cart_cubit.dart';
import 'package:models/payment_type.dart';
import 'package:local/routes.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:local/widgets/button_loading.dart';
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
  final _deliveryKey = GlobalKey();
  final _pickupKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state.cartTotal == 0) {
          Navigator.of(context).pop();
        }
        if (state.status == CartStatus.orderSuccess) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state.status == CartStatus.restaurantClosed) {
          _analytics.logEvent(name: Metric.eventCartRestaurantClosed);
          _showRestaurantClosedDialog(context);
        } else if (state.status == CartStatus.minimumOrderError) {
          _analytics.logEvent(name: Metric.eventCartMinOrder);
        } else if (state.status == CartStatus.couriersUnavailable) {
          _showCouriersUnavailableDialog(context);
          _analytics.logEvent(name: Metric.eventCartCouriersUnavailable);
        } else if (state.status == CartStatus.stripeReady) {
          initPaymentSheet(state, context.read<CartCubit>());
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).cart_title),
            bottom: state.amountToMinOrder == 0 || !state.deliverySelected
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: _getDeliveryAndMinOrderInfo(state),
                  ),
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
                          style: Theme.of(context).textTheme.displayMedium),
                      Text(
                          S.of(context).cart_order_summary(
                              state.cartCount, state.restaurantName),
                          style: Theme.of(context).textTheme.bodyMedium),
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
                                style:
                                    Theme.of(context).textTheme.displaySmall),
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
                            style: Theme.of(context).textTheme.bodyMedium),
                      ),
                      const SizedBox(height: Dimens.defaultPadding),
                      _getConfiguration(state),
                      _getPaymentMethods(state),
                      Container(
                        height: 1,
                        color: WlColors.onSurface,
                        margin: const EdgeInsets.symmetric(
                          vertical: Dimens.defaultPadding,
                        ),
                      ),
                      Text(S.of(context).cart_summary,
                          style: Theme.of(context).textTheme.displaySmall),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).cart_products,
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(
                              S.of(context).price_currency_ron(
                                  state.cartTotal.toStringAsFixed(2)),
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Visibility(
                        visible: state.hasDelivery && state.deliverySelected,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(S.of(context).cart_delivery_fee,
                                style: Theme.of(context).textTheme.titleMedium),
                            Text(
                                state.deliveryFee > 0
                                    ? S.of(context).cart_delivery_fee_currency(
                                        state.deliveryFee.toStringAsFixed(1))
                                    : S.of(context).cart_delivery_fee_free,
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(S.of(context).cart_total.toUpperCase(),
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
                          Text(
                              S.of(context).price_currency_ron(
                                  _getTotalWithDelivery(state)
                                      .toStringAsFixed(2)),
                              style:
                                  Theme.of(context).textTheme.headlineMedium),
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
                  onPressed: _isCheckoutButtonDisabled(state)
                      ? null
                      : () {
                          if (state.status == CartStatus.computingDelivery ||
                              state.status == CartStatus.stripeLoading ||
                              state.status == CartStatus.stripeReady) {
                            return;
                          }
                          _analytics.logEventWithParams(
                              name: Metric.eventCartPlaceOrder,
                              parameters: {
                                Metric.propertyOrderPrice:
                                    _getTotalWithDelivery(state),
                                Metric.propertyRestaurantsName:
                                    state.restaurantName,
                              });
                          context.read<CartCubit>().checkout();
                        },
                  child: _getCheckoutButtonWidget(state),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isCheckoutButtonDisabled(CartState state) {
    return state.status == CartStatus.minimumOrderError &&
        state.deliverySelected;
  }

  Widget _getCheckoutButtonWidget(CartState state) {
    if (state.status == CartStatus.computingDelivery ||
        state.status == CartStatus.stripeLoading) {
      return const ButtonLoading();
    }
    var text = _getCheckoutButtonText(state);
    return Text(text);
  }

  _getCheckoutButtonText(CartState state) {
    if (state.status == CartStatus.minimumOrderError) {
      return S.of(context).cart_button_min_order(state.minOrder);
    }
    return state.paymentType == PaymentType.app
        ? S.of(context).cart_confirm_payment_button
        : S.of(context).cart_confirm_button;
  }

  double _getTotalWithDelivery(CartState state) {
    return state.hasDelivery && state.deliverySelected
        ? state.cartTotal + state.deliveryFee
        : state.cartTotal;
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

  Widget _getConfiguration(CartState state) {
    if (state.hasDelivery && state.hasPickup) {
      if (state.deliverySelected) {
        return Column(
          children: [
            _getDeliveryConfigurationWidget(state),
            _getSwitchConfigurationButton(S.of(context).cart_pickup_button),
          ],
        );
      } else {
        return Column(
          children: [
            _getPickupConfigurationWidget(state),
            _getSwitchConfigurationButton(S.of(context).cart_delivery_button)
          ],
        );
      }
    } else if (state.hasDelivery) {
      return _getDeliveryConfigurationWidget(state);
    } else if (state.hasPickup) {
      return _getPickupConfigurationWidget(state);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _getDeliveryConfigurationWidget(CartState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(S.of(context).cart_delivery_headline,
            style: Theme.of(context).textTheme.displaySmall),
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
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(state.deliveryPropertyDetails,
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _getPickupConfigurationWidget(CartState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(S.of(context).cart_pickup_headline,
            style: Theme.of(context).textTheme.displaySmall),
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
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _getSwitchConfigurationButton(String buttonText) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: WlColors.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        onPressed: () {
          context.read<CartCubit>().toggleDeliverySelected();
        },
        child: Text(buttonText),
      ),
    );
  }

  Widget _getPaymentMethods(CartState state) {
    List<Widget> paymentMethods = [];
    if (state.hasPayments) {
      paymentMethods.add(
        _getPaymentTile(
          state.paymentType,
          PaymentType.app,
          S.of(context).cart_pay_app,
          Icons.wallet,
        ),
      );
    }
    if (state.hasExternalDelivery && state.deliverySelected) {
      paymentMethods.add(
        _getPaymentTile(
          state.paymentType,
          PaymentType.cash,
          S.of(context).cart_pay_delivery_cash,
          Icons.monetization_on_outlined,
        ),
      );
    }

    if (!state.hasExternalDelivery && state.deliverySelected) {
      if (state.hasDeliveryCash) {
        paymentMethods.add(
          _getPaymentTile(
            state.paymentType,
            PaymentType.cash,
            S.of(context).cart_pay_delivery_cash,
            Icons.monetization_on_outlined,
          ),
        );
      }
      if (state.hasDeliveryCard) {
        paymentMethods.add(
          _getPaymentTile(
            state.paymentType,
            PaymentType.card,
            S.of(context).cart_pay_delivery_card,
            Icons.credit_card,
          ),
        );
      }
    }

    if (!state.deliverySelected) {
      if (state.hasPickupCash) {
        paymentMethods.add(
          _getPaymentTile(
            state.paymentType,
            PaymentType.cash,
            S.of(context).cart_pay_pickup_cash,
            Icons.monetization_on_outlined,
          ),
        );
      }
      if (state.hasPickupCard) {
        paymentMethods.add(
          _getPaymentTile(
            state.paymentType,
            PaymentType.card,
            S.of(context).cart_pay_pickup_card,
            Icons.credit_card,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: Dimens.defaultPadding,
        ),
        Text(S.of(context).cart_pay_method,
            style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(
          height: 4,
        ),
        ...paymentMethods,
      ],
    );
  }

  Widget _getPaymentTile(
      PaymentType selectedType, PaymentType type, String title, IconData icon) {
    return RadioListTile<PaymentType>(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.all(0),
      value: type,
      groupValue: selectedType,
      secondary: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
      ),
      onChanged: (value) {
        context.read<CartCubit>().onPaymentTypeChanged(value!);
      },
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  Widget _getDeliveryAndMinOrderInfo(CartState state) {
    String infoText = "";
    if (state.deliveryFee == 0) {
      infoText =
          S.of(context).cart_banner_free_delivery_min_order(state.minOrder);
    } else {
      infoText = S
          .of(context)
          .cart_banner_paid_delivery_under_min_order(state.amountToMinOrder);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.info),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              infoText,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showCouriersUnavailableDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      title: S.of(context).cart_couriers_unavailable_title,
      content: S.of(context).cart_couriers_unavailable_content,
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

  Future<void> initPaymentSheet(CartState state, CartCubit cubit) async {
    try {
      final data = state.stripePayData!;
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: state.restaurantName,
          paymentIntentClientSecret: data.paymentIntentClientSecret,
          customerEphemeralKeySecret: data.ephemeralKeySecret,
          customerId: data.customer,
          primaryButtonLabel: S.of(context).cart_pay_button,
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'RO',
          ),
          googlePay: const PaymentSheetGooglePay(
              merchantCountryCode: 'RO', currencyCode: 'RON', testEnv: true),
          style: ThemeMode.light,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      cubit.placeOrder();
    } on StripeException catch (e) {
      cubit.paymentFailed();
      _handleStripeException(e);
    } catch (e) {
      cubit.paymentFailed();
      _showGenericPaymentError();
    }
  }

  _handleStripeException(StripeException e) {
    //todo log to analytics
    final error = e.error;
    context.read<CartCubit>().onPaymentFailed();
    switch (error.code) {
      case FailureCode.Failed:
        _showGenericPaymentError();
        break;
      case FailureCode.Canceled:
        // do nothing
        break;
    }
  }

  _showGenericPaymentError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).cart_payment_failed_message)),
    );
  }
}

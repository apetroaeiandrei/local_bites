import 'package:flutter/material.dart';
import 'package:models/restaurant_model.dart';

import '../generated/l10n.dart';
import '../theme/dimens.dart';
import '../utils.dart';

class HomeScreenCard extends StatelessWidget {
  const HomeScreenCard({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  final RestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      constraints: const BoxConstraints(maxHeight: Dimens.homeCardHeight),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.cardCornerRadius)),
        elevation: Dimens.profileCardElevation,
        child: Container(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                restaurant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  return defaultRestaurantImage();
                },
              ),
              Center(
                child: Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
              Center(
                child: Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
              Visibility(
                visible: restaurant.open,
                child: Positioned(
                  bottom: 0,
                  right: 0,
                  child: _getDeliveryLabel(context),
                ),
              ),
              Visibility(
                visible: restaurant.open && restaurant.maxPromo > 0,
                child: Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _getPromoLabel(context),
                ),
              ),
              Visibility(
                visible: !restaurant.open,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        S.of(context).home_restaurant_closed,
                        style:
                            Theme.of(context).textTheme.displaySmall!.copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getDeliveryLabel(BuildContext context) {
    String labelText;
    Color labelColor;
    if (restaurant.hasExternalDelivery && restaurant.couriersAvailable) {
      labelText = S.of(context).home_restaurant_external_delivery;
      labelColor = Theme.of(context).colorScheme.secondary;
    } else if (!restaurant.hasDelivery) {
      labelText = S.of(context).home_restaurant_pickup;
      labelColor = Theme.of(context).colorScheme.primary;
    } else {
      labelText = S.of(context).home_restaurant_delivery;
      labelColor = Theme.of(context).colorScheme.secondary;
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: labelColor,
      ),
      child: Text(
        labelText,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
    );
  }

  Widget _getPromoLabel(BuildContext context) {
    String labelText =
        S.of(context).home_restaurant_products_promo(restaurant.maxPromo);
    if (restaurant.hasMenuPromo) {
      labelText = S.of(context).home_restaurant_menu_promo(restaurant.maxPromo);
    }
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Center(
        child: Text(
          labelText,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:models/restaurant_model.dart';

import '../generated/l10n.dart';
import '../theme/dimens.dart';

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
              ),
              Center(
                child: Text(
                  restaurant.name,
                  style: Theme.of(context).textTheme.headline1!.copyWith(
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
                  style: Theme.of(context).textTheme.headline1!.copyWith(
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
                        style: Theme.of(context).textTheme.headline3!.copyWith(
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
    if (!restaurant.hasDelivery) {
      labelText = S.of(context).home_restaurant_pickup;
      labelColor = Theme.of(context).colorScheme.primary;
    } else if (restaurant.deliveryFee == 0) {
      labelText = S.of(context).home_restaurant_delivery_free;
      labelColor = Theme.of(context).colorScheme.secondary;
    } else {
      labelText =
          S.of(context).home_restaurant_delivery_fee(restaurant.deliveryFee);
      labelColor = Theme.of(context).colorScheme.secondary;
    }
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: labelColor,
      ),
      child: Text(
        labelText,
        style: Theme.of(context).textTheme.headline6!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
    );
  }
}

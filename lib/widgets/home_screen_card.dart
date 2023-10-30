import 'package:flutter/material.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:models/restaurant_model.dart';

import '../generated/l10n.dart';
import '../theme/dimens.dart';
import '../utils.dart';

class HomeScreenCard extends StatelessWidget {
  const HomeScreenCard({
    super.key,
    required this.restaurant,
  });

  static const int _feedbackCountThreshold = 23;
  static const double _iconsOpacity = 0.7;
  static const double _iconsSize = 16;
  final RestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
          height: Dimens.homeCardHeight,
          child: Card(
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimens.cardCornerRadius)),
            elevation: Dimens.profileCardElevation,
            child: Container(
              color: Colors.white,
              child: Stack(
                fit: StackFit.expand,
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
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        shadows: [
                          Shadow(
                              // bottomLeft
                              offset: const Offset(-1.5, -1.5),
                              color: Theme.of(context).colorScheme.primary),
                          Shadow(
                              // bottomRight
                              offset: const Offset(1.5, -1.5),
                              color: Theme.of(context).colorScheme.primary),
                          Shadow(
                              // topRight
                              offset: const Offset(1.5, 1.5),
                              color: Theme.of(context).colorScheme.primary),
                          Shadow(
                              // topLeft
                              offset: const Offset(-1.5, 1.5),
                              color: Theme.of(context).colorScheme.primary),
                        ],
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
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .copyWith(
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
        ),
        if (_showRating) _getRestaurantRating(context),
        SizedBox(height: _showRating ? 6 : 12)
      ],
    );
  }

  bool get _showRating =>
      restaurant.feedbackPositive + restaurant.feedbackNegative >
      _feedbackCountThreshold;

  Widget _getRestaurantRating(BuildContext context) {
    if (restaurant.feedbackPositive + restaurant.feedbackNegative <
        _feedbackCountThreshold) {
      return const SizedBox.shrink();
    }
    int totalRatings =
        restaurant.feedbackPositive + restaurant.feedbackNegative;
    final int rating =
        (restaurant.feedbackPositive / totalRatings * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimens.defaultPadding, 0, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: _iconsSize,
            color: Colors.black.withOpacity(_iconsOpacity),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 3.0, right: 16),
            child: Text("${restaurant.defaultEta} min"),
          ),
          Icon(
            Icons.thumb_up_alt_outlined,
            size: _iconsSize,
            color: Colors.black.withOpacity(_iconsOpacity),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3, top: 3.0),
            child: Text("$rating%"),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Text("($totalRatings)",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: WlColors.textColor.withOpacity(0.5))),
          ),
        ],
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

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
  static const double _iconsSize = 12;
  static const double _labelCornerRadius = 6;
  static const double _labelPaddingHorizontal = 6;
  static const double _labelPaddingVertical = 2;
  final RestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
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
                  Visibility(
                    visible: restaurant.open && restaurant.maxPromo > 0,
                    child: Positioned(
                      top: 12,
                      left: 10,
                      child: _getPromoLabel(context),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Visibility(
                              visible: restaurant.stripeConfigured,
                              child: Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Icon(
                                  Icons.credit_card,
                                  size: _iconsSize,
                                  color:
                                      Colors.black.withOpacity(_iconsOpacity),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: restaurant.acceptsVouchers,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Icon(
                                  Icons.discount_outlined,
                                  size: _iconsSize,
                                  color:
                                      Colors.black.withOpacity(_iconsOpacity),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: _showRating,
                          child: Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              vertical: _labelPaddingVertical,
                              horizontal: _labelPaddingHorizontal,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(_labelCornerRadius)),
                            ),
                            child: _getRestaurantRating(context),
                          ),
                        ),
                      ],
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    _getTimer(context),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _getDeliveryLabel(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool get _showRating =>
      restaurant.feedbackPositive + restaurant.feedbackNegative >
      _feedbackCountThreshold;

  Widget _getTimer(BuildContext context) {
    if (!restaurant.open) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.timer_outlined,
          size: _iconsSize,
          color: Colors.black.withOpacity(_iconsOpacity),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(
            "${restaurant.defaultEta} min",
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(letterSpacing: -0.2),
          ),
        ),
      ],
    );
  }

  Widget _getRestaurantRating(BuildContext context) {
    if (restaurant.feedbackPositive + restaurant.feedbackNegative <
        _feedbackCountThreshold) {
      return const SizedBox.shrink();
    }
    int totalRatings =
        restaurant.feedbackPositive + restaurant.feedbackNegative;
    final int rating =
        (restaurant.feedbackPositive / totalRatings * 100).round();

    final TextStyle ratingStyle =
        Theme.of(context).textTheme.labelSmall!.copyWith(letterSpacing: -0.2);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.thumb_up_alt_outlined,
          size: _iconsSize,
          color: Colors.black.withOpacity(_iconsOpacity),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Text(
            "$rating%",
            style: ratingStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Text("($totalRatings)",
              style: ratingStyle.copyWith(
                  color: WlColors.textColor.withOpacity(0.5))),
        ),
      ],
    );
  }

  Widget _getDeliveryLabel(BuildContext context) {
    String labelText;
    if (restaurant.hasExternalDelivery && restaurant.couriersAvailable) {
      labelText = S.of(context).home_restaurant_external_delivery;
    } else if (!restaurant.hasDelivery) {
      labelText = S.of(context).home_restaurant_pickup;
    } else {
      labelText = S.of(context).home_restaurant_delivery;
    }
    return Text(
      labelText,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 11,
            letterSpacing: -0.1,
            color: WlColors.textColor.withOpacity(0.7),
          ),
    );
  }

  Widget _getPromoLabel(BuildContext context) {
    String labelText =
        S.of(context).home_restaurant_products_promo(restaurant.maxPromo);
    if (restaurant.hasMenuPromo) {
      labelText = S.of(context).home_restaurant_menu_promo(restaurant.maxPromo);
    }
    return _getOverlayLabel(
        context, labelText, Theme.of(context).colorScheme.primary);
  }

  Widget _getOverlayLabel(
    BuildContext context,
    String text,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: _labelPaddingVertical,
        horizontal: _labelPaddingHorizontal,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
            const BorderRadius.all(Radius.circular(_labelCornerRadius)),
      ),
      child: Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
      ),
    );
  }
}

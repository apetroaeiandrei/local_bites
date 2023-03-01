import 'package:flutter/material.dart';
import 'package:local/widgets/circular_icon_button.dart';
import 'package:models/food_model.dart';

import '../generated/l10n.dart';
import '../theme/dimens.dart';
import '../utils.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    Key? key,
    required this.foodModel,
  }) : super(key: key);
  final FoodModel foodModel;
  static const _nameMaxLines = 2;

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Colors.grey.withOpacity(foodModel.available ? 0 : 0.8),
        BlendMode.srcATop,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 28),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: Dimens.foodCardPhotoSize,
                  height: Dimens.foodCardPhotoSize,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Dimens.foodCardPhotoRadius),
                  ),
                  child: foodModel.imageUrl.isNotEmpty
                      ? Image.network(
                          foodModel.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) {
                            return defaultFoodImage();
                          },
                        )
                      : defaultFoodImage(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!foodModel.available)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(S.of(context).food_unavailable,
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                foodModel.name,
                                maxLines: _nameMaxLines,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              S.of(context).price_currency_ron(
                                  foodModel.discountedPrice > 0
                                      ? foodModel.discountedPrice
                                          .toStringAsFixed(1)
                                      : foodModel.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: foodModel.discountedPrice > 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : null),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  foodModel.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Visibility(
                                visible: foodModel.discountedPrice > 0,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: Text(
                                  S
                                      .of(context)
                                      .price_currency_ron(foodModel.price),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                          color:
                                              Theme.of(context).disabledColor,
                                          decoration:
                                              TextDecoration.lineThrough),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Visibility(
                visible: foodModel.available,
                child: const CircularIconButton(
                  icon: Icons.add,
                  onTap: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

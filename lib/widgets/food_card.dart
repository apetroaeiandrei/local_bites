import 'package:flutter/material.dart';
import 'package:models/food_model.dart';

import '../generated/l10n.dart';
import '../img.dart';
import '../theme/dimens.dart';
import '../utils.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    Key? key,
    required this.foodModel,
  }) : super(key: key);
  final FoodModel foodModel;
  static const _descriptionMaxLines = 2;
  static const _nameMaxLines = 2;
  static const _verticalPadding = 10.0;
  static const _textsSpacing = 8.0;
  static const _cardOutsidePadding = 10.0;

  double _getCardHeight(BuildContext context) {
    final scale = MediaQuery.of(context).textScaleFactor;

    double bodyFontSize = Theme.of(context).textTheme.bodyText2?.fontSize ?? 0;
    double bodyLineHeight = bodyFontSize * scale;

    double titleFontSize = Theme.of(context).textTheme.headline5?.fontSize ?? 0;
    double titleLineHeight = titleFontSize * scale;

    double priceFontSize = Theme.of(context).textTheme.headline6?.fontSize ?? 0;
    double priceLineHeight = priceFontSize * scale;

    final textsHeight = (titleLineHeight * _nameMaxLines) +
        (bodyLineHeight * _descriptionMaxLines);
    var cardHeight = textsHeight +
        _verticalPadding * 2 +
        _textsSpacing * 3 +
        priceLineHeight +
        _cardOutsidePadding * 2;

    return cardHeight;
  }

  @override
  Widget build(BuildContext context) {
    final cardHeight = _getCardHeight(context);
    final isEn = Utils.useEnStrings(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
          _cardOutsidePadding, _cardOutsidePadding, _cardOutsidePadding, 0),
      height: cardHeight,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.cardCornerRadius)),
        elevation: Dimens.profileCardElevation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    12, _verticalPadding, 4, _verticalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? foodModel.nameEn : foodModel.name,
                      maxLines: _nameMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(
                      height: _textsSpacing,
                    ),
                    Text(
                      isEn ? foodModel.descriptionEn : foodModel.description,
                      maxLines: _descriptionMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    const Spacer(),
                    Text(
                      S.of(context).price_currency_ron(foodModel.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: Dimens.foodCardPhotoWidth,
              height: cardHeight,
              child: foodModel.imageUrl.isNotEmpty
                  ? Image.network(
                      foodModel.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return defaultImage();
                      },
                    )
                  : defaultImage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget defaultImage() => Image.asset(
        Img.foodPlaceholder,
        fit: BoxFit.cover,
      );
}

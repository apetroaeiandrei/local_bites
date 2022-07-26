import 'package:flutter/material.dart';
import 'package:models/food_model.dart';

import '../generated/l10n.dart';
import '../img.dart';
import '../theme/dimens.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    Key? key,
    required this.foodModel,
  }) : super(key: key);
  final FoodModel foodModel;
  static const _nameMaxLines = 2;
  static const _textsSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          return defaultImage();
                        },
                      )
                    : defaultImage(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              foodModel.name,
                              maxLines: _nameMaxLines,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            S.of(context).price_currency_ron(foodModel.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline5,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: _textsSpacing,
                      ),
                      Text(
                        foodModel.description,
                        style: Theme.of(context).textTheme.bodyText2,
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
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).iconTheme.color!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget defaultImage() => Image.asset(
        Img.foodPlaceholder,
        fit: BoxFit.cover,
      );
}

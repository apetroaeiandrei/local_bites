import 'package:flutter/material.dart';
import 'package:local/widgets/circular_icon_button.dart';
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
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 70),
                        child: Text(
                          foodModel.description,
                          style: Theme.of(context).textTheme.bodyText2,
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
            child: CircularIconButton(
              icon: Icons.add,
              onTap: () {},
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

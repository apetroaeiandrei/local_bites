import 'package:flutter/material.dart';
import 'package:local/widgets/circular_icon_button.dart';
import 'package:models/food_order.dart';

import '../environment/env.dart';
import '../generated/l10n.dart';

class CartItem extends StatelessWidget {
  const CartItem(
      {super.key,
      required this.item,
      this.showAddRemoveButtons = false,
      this.onAdd,
      this.onRemove});

  final FoodOrder item;
  final bool showAddRemoveButtons;
  final Function()? onAdd;
  final Function()? onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${item.quantity} x",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.food.name.toString(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Text(
              S.of(context).price_currency_ron(
                  double.parse(item.price.toStringAsFixed(2)),
                  EnvProd.currency),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "${item.quantity} x",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: Colors.transparent),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _getOptions(item),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Visibility(
          visible: showAddRemoveButtons,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircularIconButton(
                icon: Icons.remove,
                onTap: onRemove,
              ),
              CircularIconButton(
                icon: Icons.add,
                onTap: onAdd,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  String _getOptions(FoodOrder item) {
    if (item.selectedOptions.isEmpty) {
      return '';
    }
    return item.selectedOptions.entries.map((e) {
      return e.value.map((i) => i).join(', ');
    }).join('\n');
  }
}

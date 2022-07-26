import 'package:flutter/material.dart';
import 'package:models/food_order.dart';

import '../generated/l10n.dart';

class CartItem extends StatelessWidget {
  const CartItem({Key? key, required this.item}) : super(key: key);
  final FoodOrder item;

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
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                item.food.name.toString(),
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            Text(
              S.of(context).price_currency_ron(item.price),
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              "${item.quantity} x",
              style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.transparent),
            ),
            const SizedBox(width: 4),
            Expanded(child: Text(_getOptions(item))),
          ],
        ),
        const SizedBox(height: 12),
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

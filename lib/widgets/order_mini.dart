import 'package:flutter/material.dart';
import 'package:local/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:models/user_order.dart';

import '../generated/l10n.dart';

class OrderMini extends StatelessWidget {
  const OrderMini({Key? key, required this.order}) : super(key: key);
  final UserOrder order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            order.status.toLottieResource(),
            width: 100,
            height: 100,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  order.restaurantName,
                  style: Theme.of(context).textTheme.headline3,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  order.status.toUserString(context),
                  style: Theme.of(context).textTheme.headline3?.copyWith(
                        color: order.status.toTextColor(),
                      ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  S.of(context).price_currency_ron(order.total),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

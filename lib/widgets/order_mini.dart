import 'package:flutter/material.dart';
import 'package:local/theme/dimens.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:local/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:models/order_status.dart';
import 'package:models/user_order.dart';

import '../generated/l10n.dart';
import '../img.dart';

class OrderMini extends StatelessWidget {
  const OrderMini({Key? key, required this.order}) : super(key: key);
  final UserOrder order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10,0,10,20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            getLottieForStatus(order.status),
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
                  style: Theme.of(context)
                      .textTheme
                      .headline3
                      ?.copyWith(color: getColorForStatus(order.status)),
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

  Color getColorForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.cooking:
        return WlColors.primary;
      case OrderStatus.readyForDelivery:
        return Colors.orangeAccent;
      case OrderStatus.inDelivery:
        return WlColors.notificationGreen;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String getLottieForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Img.lottiePendingFood;
      case OrderStatus.cooking:
        return Img.lottiePreparingFood;
      case OrderStatus.readyForDelivery:
        return Img.lottieReadyForDelivery;
      case OrderStatus.inDelivery:
        return Img.lottieDeliveringFood;
      case OrderStatus.completed:
        return Img.lottieDeliveredFood;
      case OrderStatus.cancelled:
        return Img.lottieCancelledFood;
    }
  }
}

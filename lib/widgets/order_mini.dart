import 'package:flutter/material.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:local/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:models/order_status.dart';
import 'package:models/user_order.dart';

import '../generated/l10n.dart';

class OrderMini extends StatelessWidget {
  const OrderMini({Key? key, required this.order, required this.onFeedback})
      : super(key: key);
  final UserOrder order;
  final Function(bool? liked) onFeedback;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: CloseButton(
            onPressed: () {
              onFeedback(null);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
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
                          height: 2,
                        ),
                        Text(
                          order.date.toUserString(),
                          style: Theme.of(context).textTheme.headline5,
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
              Visibility(
                visible: order.status == OrderStatus.completed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        onFeedback(false);
                      },
                      icon: const Icon(
                        Icons.thumb_down_alt_outlined,
                        color: WlColors.error,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        onFeedback(true);
                      },
                      icon: const Icon(
                        Icons.thumb_up_alt_outlined,
                        color: WlColors.notificationGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

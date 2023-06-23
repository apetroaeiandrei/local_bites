import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:local/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:models/order_status.dart';
import 'package:models/payment_type.dart';
import 'package:models/user_order.dart';

import '../generated/l10n.dart';

class OrderMini extends StatelessWidget {
  const OrderMini({Key? key, required this.order, required this.onFeedback})
      : super(key: key);
  final UserOrder order;
  final Function(bool? liked) onFeedback;
  static const _orderMiniHeight = 210.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      height: _orderMiniHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      order.restaurantName,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Visibility(
                      visible: _isEtaVisible(),
                      child: Text(
                        _getEta(context, order),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      order.status.toUserString(context),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                            color: order.status.toTextColor(),
                          ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Visibility(
                      visible: order.status == OrderStatus.cancelled &&
                          order.paymentType == PaymentType.app,
                      child: Text(S.of(context).order_mini_refund_info),
                    ),
                    Text(
                      S.of(context).price_currency_ron(
                          order.total.toStringAsFixed(2)),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Visibility(
            visible: order.status == OrderStatus.completed ||
                order.status == OrderStatus.cancelled,
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
    );
  }

  bool _isEtaVisible() {
    return order.eta != 0 &&
        !(order.status == OrderStatus.completed ||
            order.status == OrderStatus.cancelled);
  }

  String _getEta(BuildContext context, UserOrder order) {
    final eta = order.date.add(Duration(minutes: order.eta));
    DateFormat dateFormat = DateFormat('HH:mm');
    final etaString = dateFormat.format(eta);
    if (order.isDelivery) {
      return S.of(context).order_mini_delivery_eta(etaString);
    } else {
      return S.of(context).order_mini_pickup_eta(etaString);
    }
  }
}

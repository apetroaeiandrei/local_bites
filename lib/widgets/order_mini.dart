import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local/utils.dart';
import 'package:local/widgets/button_loading.dart';
import 'package:lottie/lottie.dart';
import 'package:models/order_status.dart';
import 'package:models/payment_type.dart';
import 'package:models/user_order.dart';

import '../generated/l10n.dart';

class OrderMini extends StatefulWidget {
  const OrderMini(
      {super.key,
      required this.order,
      required this.onFeedback,
      required this.onOrderCancelled});
  final UserOrder order;
  final Function(bool liked) onFeedback;
  final Function(UserOrder order) onOrderCancelled;

  @override
  State<OrderMini> createState() => _OrderMiniState();
}

class _OrderMiniState extends State<OrderMini> {
  static const _cancelOrderButtonTimeSeconds = 60;
  static const _orderMiniHeight = 210.0;

  @override
  void initState() {
    _checkCancelButtonAfterOneMin();
    super.initState();
  }

  bool _cancellingOrder = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      height: _orderMiniHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                widget.order.status.toLottieResource(),
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
                      widget.order.restaurantName,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Visibility(
                      visible: _isEtaVisible(),
                      child: Text(
                        _getEta(context, widget.order),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.order.status.toUserString(context),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: widget.order.status.toTextColor(),
                          ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Visibility(
                      visible: widget.order.status == OrderStatus.cancelled &&
                          widget.order.paymentType == PaymentType.app,
                      child: Text(S.of(context).order_mini_refund_info),
                    ),
                    Text(
                      S.of(context).price_currency_ron(
                          widget.order.total.toStringAsFixed(2)),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Visibility(
            visible: widget.order.status == OrderStatus.completed ||
                widget.order.status == OrderStatus.cancelled,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: ElevatedButton(
                onPressed: () {
                  widget.onFeedback(true);
                },
                child: Text(S.of(context).order_mini_show_feedback_button),
              ),
            ),
          ),
          Visibility(
            visible: _cancelButtonVisible(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (!_cancellingOrder) {
                    widget.onOrderCancelled(widget.order);
                  }
                  setState(() {
                    _cancellingOrder = true;
                  });
                },
                child: _cancellingOrder
                    ? const ButtonLoading()
                    : Text(S.of(context).order_mini_cancel_button),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkCancelButtonAfterOneMin() {
    if (_cancelButtonVisible()) {
      return;
    }
    Future.delayed(const Duration(seconds: _cancelOrderButtonTimeSeconds + 10),
        () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  bool _cancelButtonVisible() {
    return widget.order.status == OrderStatus.pending &&
        DateTime.now().difference(widget.order.date).inSeconds >
            _cancelOrderButtonTimeSeconds;
  }

  bool _isEtaVisible() {
    return widget.order.eta != 0 &&
        !(widget.order.status == OrderStatus.completed ||
            widget.order.status == OrderStatus.cancelled);
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

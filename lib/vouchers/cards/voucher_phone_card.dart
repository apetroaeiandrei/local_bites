import 'package:flutter/material.dart';
import 'package:local/vouchers/cards/voucher_painter.dart';

import '../../generated/l10n.dart';

class VoucherPhoneCard extends StatelessWidget {
  const VoucherPhoneCard(
      {Key? key,
      required this.title,
      required this.value,
      required this.expiryDate})
      : super(key: key);
  final String title;
  final double value;
  final DateTime expiryDate;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: VoucherPainter(),
      child: Container(
        height: 130,
        padding: const EdgeInsets.fromLTRB(66, 16, 30, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const Spacer(),
            Text(S.of(context).voucher_card_value(value.toStringAsFixed(0)),
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(
              height: 4,
            ),
            Text(
                S.of(context).voucher_card_expiration_interval(
                    _getExpirationIntervalDays()),
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  int _getExpirationIntervalDays() {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    return difference.inDays;
  }
}

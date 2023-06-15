import 'package:flutter/material.dart';
import 'package:local/vouchers/cards/voucher_painter.dart';
import 'package:models/vouchers/voucher.dart';

import '../../generated/l10n.dart';

class VoucherCartCard extends StatelessWidget {
  const VoucherCartCard({super.key, required this.voucher});

  final Voucher voucher;

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
            Center(
              child: Text(
                S.of(context).price_currency_ron(
                      voucher.value.toStringAsFixed(0),
                    ),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            const Spacer(),
            Text(
                S.of(context).voucher_card_min_purchase(
                      voucher.minPurchase.toStringAsFixed(0),
                    ),
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
    final difference = voucher.expiryDate.difference(now);
    return difference.inDays;
  }
}

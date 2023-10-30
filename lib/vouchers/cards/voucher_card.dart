import 'package:flutter/material.dart';
import 'package:local/vouchers/cards/voucher_border.dart';
import 'package:models/vouchers/voucher.dart';

import '../../generated/l10n.dart';
import '../../theme/dimens.dart';

class VoucherCard extends StatelessWidget {
  const VoucherCard(
      {super.key, required this.voucher, required this.isCartVoucher});
  final Voucher voucher;
  final bool isCartVoucher;
  final double voucherHeight = 130;
  final double voucherVerticalPadding = 16;
  final double maxStarSize = 25;
  final int maxStars = 5;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: VoucherBorder(),
      child: Container(
        height: voucherHeight,
        padding: EdgeInsets.symmetric(vertical: voucherVerticalPadding),
        child: Row(
          children: [
            Expanded(
              flex: Dimens.voucherDashLeftFlex,
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    voucher.id.substring(0, 5).toUpperCase(),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: Dimens.voucherDashRightFlex,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        S.of(context).price_currency_ron(
                            voucher.value.toStringAsFixed(0)),
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                        isCartVoucher
                            ? S.of(context).voucher_card_min_purchase(
                                voucher.minPurchase.roundToDouble())
                            : voucher.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(_getExpirationDaysText(context),
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getExpirationIntervalDays() {
    if (voucher.expiryDate.isBefore(DateTime.now())) {
      return -1;
    }

    final now = DateTime.now();
    final difference = voucher.expiryDate.difference(now);
    return difference.inDays;
  }

  String _getExpirationDaysText(BuildContext context) {
    final days = _getExpirationIntervalDays();
    if (days == 0) {
      return S.of(context).voucher_card_expiration_today;
    } else if (days == 1) {
      return S.of(context).voucher_card_expiration_tomorrow;
    } else if (days < 0) {
      return S.of(context).voucher_card_expiration_expired;
    } else {
      return S.of(context).voucher_card_expiration_interval(days);
    }
  }
}

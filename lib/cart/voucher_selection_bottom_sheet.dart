import 'package:flutter/material.dart';
import 'package:local/vouchers/cards/voucher_cart_card.dart';
import 'package:models/vouchers/voucher.dart';

class VoucherSelectionBottomSheet extends StatelessWidget {
  const VoucherSelectionBottomSheet(
      {super.key,
      required this.vouchers,
      required this.onVoucherSelected,
      required this.cartTotalProducts});

  final List<Voucher> vouchers;
  final Function(Voucher) onVoucherSelected;
  final double cartTotalProducts;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 16);
      },
      itemBuilder: (BuildContext context, int index) {
        final voucher = vouchers[index];
        return InkWell(
          onTap: () {
            if (voucher.minPurchase > cartTotalProducts) {
              return;
            }
            onVoucherSelected(voucher);
          },
          child: VoucherCartCard(
            voucher: voucher,
          ),
        );
      },
      itemCount: vouchers.length,
    );
  }
}

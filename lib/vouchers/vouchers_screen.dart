import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/vouchers/cards/voucher_card.dart';
import 'package:local/vouchers/vouchers_cubit.dart';
import 'package:lottie/lottie.dart';

import '../generated/l10n.dart';
import '../img.dart';
import '../routes.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({Key? key}) : super(key: key);

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  final List<Widget> _listViewWidgets = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VouchersCubit, VouchersState>(
      listener: (context, state) {
        print("VouchersScreen: listener: $state");
      },
      builder: (context, state) {
        _buildWidgetList(state);
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).vouchers_title),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(height: 16);
            },
            itemBuilder: (BuildContext context, int index) {
              return _listViewWidgets[index];
            },
            itemCount: _listViewWidgets.length,
          ),
        );
      },
    );
  }

  _buildWidgetList(VouchersState state) {
    print("Building widget list");
    _listViewWidgets.clear();
    //Verify phone number widget
    if (!state.phoneVerified) {
      _listViewWidgets.add(
        _getConfirmPhoneWidget(),
      );
    }

    state.vouchers
        .map((e) => _listViewWidgets.add(VoucherCard(
              voucher: e,
              isCartVoucher: false,
            )))
        .toList();
    print("Widget list length: ${_listViewWidgets.length}");
  }

  Widget _getConfirmPhoneWidget() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Lottie.asset(
            Img.lottieConfirmPerson,
            width: 80,
            height: 80,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.of(context).vouchers_phone_number_rationale,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  S.of(context).vouchers_phone_number_bonus,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(Routes.phone);
                  },
                  child: Text(
                    S.of(context).vouchers_phone_number_button,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

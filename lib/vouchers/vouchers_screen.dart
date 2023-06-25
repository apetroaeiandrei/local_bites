import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/analytics/metric.dart';
import 'package:local/vouchers/cards/voucher_card.dart';
import 'package:local/vouchers/vouchers_cubit.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

import '../generated/l10n.dart';
import '../img.dart';
import '../routes.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({Key? key}) : super(key: key);

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  final _analytics = Analytics();
  final List<Widget> _listViewWidgets = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VouchersCubit, VouchersState>(
      listener: (context, state) {},
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
    bool hasTopWigdets = false;
    _listViewWidgets.clear();
    //Verify phone number widget
    if (!state.phoneVerified) {
      hasTopWigdets = true;
      _listViewWidgets.add(
        _getConfirmPhoneWidget(),
      );
    }

    if (state.referralEnabled) {
      hasTopWigdets = true;
      _listViewWidgets.add(
        _getReferralWidget(state),
      );
    }

    if (hasTopWigdets) {
      //Add separator
      _listViewWidgets.add(
        Container(
          height: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (state.vouchers.isNotEmpty) {
      state.vouchers
          .map((e) => _listViewWidgets.add(VoucherCard(
                voucher: e,
                isCartVoucher: false,
              )))
          .toList();
    } else {
      _listViewWidgets.add(_getEmptyVouchersWidget());
    }
  }

  Widget _getEmptyVouchersWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(Img.emptyPlate),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            S.of(context).vouchers_empty_screen,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        )
      ],
    );
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

  Widget _getReferralWidget(VouchersState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
      child: Row(
        children: [
          Lottie.asset(
            Img.lottieSendInvitation,
            width: 90,
            height: 90,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.of(context).vouchers_referral_rationale,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  S.of(context).vouchers_referral_code(state.referralCode),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  S.of(context).vouchers_referral_bonus(
                      state.referralValue.toStringAsFixed(0)),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _analytics.logEvent(name: Metric.eventVouchersInviteFriend);
                    Share.share(
                        S.of(context).vouchers_referral_share_message(
                            state.referralCode),
                        subject: S.of(context).vouchers_referral_share_subject);
                  },
                  child: Text(
                    S.of(context).vouchers_referral_button,
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

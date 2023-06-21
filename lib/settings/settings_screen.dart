import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/routes.dart';
import 'package:local/settings/settings_cubit.dart';
import 'package:local/widgets/custom_menu_item.dart';
import 'package:url_launcher/url_launcher.dart';

import '../analytics/analytics.dart';
import '../analytics/metric.dart';
import '../constants.dart';
import '../generated/l10n.dart';
import '../theme/dimens.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);
  final _analytics = Analytics();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.isLoggedIn) {
        } else {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.auth, (route) => false);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).settings_title),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Dimens.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Dimens.defaultPadding,
                      bottom: Dimens.defaultPadding,
                    ),
                    child: Text(S.of(context).settings_welcome(state.name),
                        style: Theme.of(context).textTheme.displayMedium),
                  ),
                  CustomMenuItem(
                      name: S.of(context).settings_profile,
                      onTap: () {
                        _analytics.setCurrentScreen(screenName: Routes.profile);
                        Navigator.of(context)
                            .pushNamed(Routes.profile, arguments: false)
                            .then((value) => _analytics.setCurrentScreen(
                                screenName: Routes.settings));
                      }),
                  CustomMenuItem(
                      name: S.of(context).settings_notifications,
                      onTap: () {
                        _analytics.setCurrentScreen(
                            screenName: Routes.notifications);
                        Navigator.of(context)
                            .pushNamed(Routes.notifications)
                            .then((value) => _analytics.setCurrentScreen(
                                screenName: Routes.settings));
                      }),
                  CustomMenuItem(
                      name: S.of(context).settings_orders,
                      onTap: () {
                        _analytics.setCurrentScreen(screenName: Routes.orders);
                        Navigator.of(context).pushNamed(Routes.orders).then(
                            (value) => _analytics.setCurrentScreen(
                                screenName: Routes.settings));
                      }),
                  CustomMenuItem(
                      name: S.of(context).settings_terms,
                      onTap: () {
                        _analytics.logEvent(name: Metric.eventTC);
                        launchUrl(Uri.parse(Constants.tcUrl));
                      }),
                  CustomMenuItem(
                      name: S.of(context).settings_help,
                      onTap: () {
                        _analytics.setCurrentScreen(screenName: Routes.help);
                        Navigator.of(context).pushNamed(Routes.help).then(
                            (value) => _analytics.setCurrentScreen(
                                screenName: Routes.settings));
                      }),
                  CustomMenuItem(
                      name: S.of(context).settings_logout,
                      onTap: () {
                        _analytics.logEvent(name: Metric.eventLogout);
                        context.read<SettingsCubit>().logout();
                      }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

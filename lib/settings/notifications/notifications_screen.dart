import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/settings/notifications/notifications_cubit.dart';
import 'package:local/theme/dimens.dart';

import '../../analytics/metric.dart';
import '../../generated/l10n.dart';
import '../../widgets/dialog_utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<NotificationsCubit>().onAppLifecycleStateChanged(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsCubit, NotificationsState>(
        listener: (context, state) {
      if (state.showSettingsDialog) {
        _showNotificationSettingsDialog();
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).notifications_title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(Dimens.defaultPadding),
          child: Column(
            children: [
              Text(
                S.of(context).notifications_description,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(
                height: Dimens.defaultPadding,
              ),
              SwitchListTile(
                title: Text(S.of(context).notifications_promo_title,
                    style: Theme.of(context).textTheme.headlineMedium),
                subtitle: Text(S.of(context).notifications_promo_description),
                value: state.hasTopicPromo,
                onChanged: (value) {
                  context.read<NotificationsCubit>().toggleTopicPromo();
                },
              ),
              const SizedBox(
                height: 40,
              ),
              if (!state.notificationsEnabled) _getNotificationsBanner(),
            ],
          ),
        ),
      );
    });
  }

  Widget _getNotificationsBanner() {
    return InkWell(
      onTap: () {
        context.read<NotificationsCubit>().onWantNotificationsClick();
      },
      child: Container(
        padding: const EdgeInsets.all(Dimens.defaultPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimens.cardCornerRadius),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Center(
          child: Text(
            S.of(context).notifications_banner_permission_denied,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
        ),
      ),
    );
  }

  _showNotificationSettingsDialog() {
    final Analytics analytics = Analytics();
    final List<Widget> actions = [
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          analytics.logEvent(name: Metric.eventNotificationsDialogCancel);
        },
        child: Text(S.of(context).home_notifications_dialog_cancel),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          analytics.logEvent(name: Metric.eventNotificationsDialogConfirm);
          AppSettings.openNotificationSettings();
        },
        child: Text(S.of(context).home_notifications_dialog_ok),
      ),
    ];

    showPlatformDialog(
      context: context,
      title: S.of(context).home_notifications_dialog_title,
      content: S.of(context).home_notifications_dialog_content,
      actions: actions,
    );
  }
}

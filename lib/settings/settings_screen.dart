import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/routes.dart';
import 'package:local/settings/settings_cubit.dart';
import 'package:local/widgets/custom_menu_item.dart';

import '../generated/l10n.dart';
import '../theme/dimens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
                    padding: const EdgeInsets.all(Dimens.defaultPadding),
                    child: Text(S.of(context).settings_welcome(state.name),
                        style: Theme.of(context).textTheme.headline2),
                  ),
                  CustomMenuItem(
                      name: S.of(context).settings_profile,
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.profile);
                      }),
                  CustomMenuItem(
                      name: S.of(context).settings_logout,
                      onTap: () {
                        context.read<SettingsCubit>().logout();
                      }),
                  CustomMenuItem(
                      name: S.of(context).settings_orders,
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.orders);
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

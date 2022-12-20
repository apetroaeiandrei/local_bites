import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/profile/profile_cubit.dart';
import 'package:local/profile/profile_state.dart';
import 'package:local/routes.dart';

import '../analytics/analytics.dart';
import '../analytics/metric.dart';
import '../generated/l10n.dart';
import '../theme/decorations.dart';
import '../theme/dimens.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _analytics = Analytics();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        _nameController.text = state.name;
        _phoneController.text = state.phoneNumber;
        if (state.status == ProfileStatus.success) {
          _analytics.logEvent(name: Metric.eventProfileSaveSuccess);
          Navigator.of(context).pop();
        } else if (state.status == ProfileStatus.failure) {
          _analytics.logEvent(name: Metric.eventProfileSaveError);
        } else if (state.status == ProfileStatus.deleted) {
          _analytics.logEvent(name: Metric.eventProfileDelete);
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.auth, (route) => false);
        } else if (state.status == ProfileStatus.deletedFailure) {
          _analytics.logEvent(name: Metric.eventProfileDeleteError);
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            final canGoBack =
                state.name.isNotEmpty && state.phoneNumber.isNotEmpty;
            if (!canGoBack) {
              _analytics.logEvent(name: Metric.eventProfileNavigateBackBlock);
            }
            return canGoBack;
          },
          child: Scaffold(
            appBar: AppBar(
              leading: state.name.isEmpty ? const SizedBox() : null,
              title: Text(
                S.of(context).profile_user_details,
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Dimens.defaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.name,
                        decoration:
                            textFieldDecoration(S.of(context).profile_name),
                        controller: _nameController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: textFieldDecoration(
                            S.of(context).profile_phone_number),
                        controller: _phoneController,
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileCubit>().setUserDetails(
                            _nameController.text, _phoneController.text);
                      },
                      child: Text(S.of(context).generic_save),
                    ),
                    const SizedBox(
                      height: Dimens.defaultPadding,
                    ),
                    const Divider(),
                    Text(
                      S.of(context).profile_delete_account_headline,
                      style: Theme.of(context).textTheme.headline3,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(S.of(context).profile_delete_account_info,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    const SizedBox(
                      height: Dimens.defaultPadding,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileCubit>().deleteUser();
                      },
                      child: Text(S.of(context).profile_delete_account_button),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

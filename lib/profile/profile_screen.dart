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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _referredByController = TextEditingController();

  final _analytics = Analytics();
  String? _nameError;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        _nameController.text = state.name;
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
          Navigator.of(context)
              .pushNamed(Routes.deleteConfirmation)
              .then((value) => {
                    if (value != null && value as bool)
                      {context.read<ProfileCubit>().deleteUser()}
                    else
                      {context.read<ProfileCubit>().retry()}
                  });
          _analytics.logEvent(name: Metric.eventProfileDeleteError);
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            final canGoBack = state.name.isNotEmpty;
            if (!canGoBack) {
              _analytics.logEvent(name: Metric.eventProfileNavigateBackBlock);
            }
            return true;
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
                child: AutofillGroup(
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
                          autofillHints: const [AutofillHints.name],
                          decoration: textFieldDecoration(
                              label: S.of(context).profile_name,
                              error: _nameError),
                          controller: _nameController,
                        ),
                      ),
                      const SizedBox(
                        height: Dimens.defaultPadding,
                      ),
                      Visibility(
                        visible: state.firstTime,
                        child: TextField(
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.characters,
                          decoration: textFieldDecoration(
                            label: S.of(context).profile_referred_by,
                          ),
                          controller: _referredByController,
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (!validate()) {
                            return;
                          }
                          context.read<ProfileCubit>().setUserDetails(
                              _nameController.text,
                              referredBy: _referredByController.text);
                        },
                        child: Text(S.of(context).generic_save),
                      ),
                      const SizedBox(
                        height: Dimens.defaultPadding,
                      ),
                      const Divider(),
                      Text(
                        S.of(context).profile_delete_account_headline,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        S.of(context).profile_delete_account_info,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(
                        height: Dimens.defaultPadding,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ProfileCubit>().deleteUser();
                        },
                        child:
                            Text(S.of(context).profile_delete_account_button),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool validate() {
    var isValid = true;
    if (!_isNameValid(_nameController.text)) {
      isValid = false;
    }
    return isValid;
  }

  bool _isNameValid(String name) {
    if (name.length >= 3) {
      setState(() {
        _nameError = null;
      });
      return true;
    } else {
      setState(() {
        _nameError = S.of(context).register_name_error;
      });
      return false;
    }
  }
}

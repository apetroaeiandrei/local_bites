import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/profile/profile_cubit.dart';
import 'package:local/profile/profile_state.dart';
import 'package:local/routes.dart';

import '../analytics/analytics.dart';
import '../analytics/metric.dart';
import '../constants.dart';
import '../generated/l10n.dart';
import '../theme/decorations.dart';
import '../theme/dimens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _analytics = Analytics();
  String? _phoneError;
  String? _nameError;

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
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          decoration: textFieldDecoration(
                              label: S.of(context).profile_phone_number,
                              error: _phoneError),
                          controller: _phoneController,
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
                      Text(
                        S.of(context).profile_delete_account_info,
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
          ),
        );
      },
    );
  }

  bool validate() {
    var isValid = true;
    if (!_isPhoneValid(_phoneController.text)) {
      isValid = false;
    }
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

  bool _isPhoneValid(String phone) {
    final phoneRegexp = RegExp(Constants.phoneRegex);
    phone = phone.replaceAll(' ', '');
    if (phoneRegexp.hasMatch(phone)) {
      setState(() {
        _phoneError = null;
      });
      return true;
    } else {
      setState(() {
        _phoneError = S.of(context).register_phone_error;
      });
      return false;
    }
  }
}

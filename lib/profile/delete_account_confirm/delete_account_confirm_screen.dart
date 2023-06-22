import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:local/profile/delete_account_confirm/delete_account_confirm_cubit.dart';

import '../../analytics/analytics.dart';
import '../../analytics/metric.dart';
import '../../auth/auth_status.dart';
import '../../constants.dart';
import '../../generated/l10n.dart';
import '../../repos/phone_confirm_error.dart';
import '../../theme/decorations.dart';
import '../../theme/dimens.dart';
import '../../theme/wl_colors.dart';
import '../../utils.dart';
import '../../widgets/button_loading.dart';

class DeleteAccountConfirmScreen extends StatefulWidget {
  const DeleteAccountConfirmScreen({super.key});

  @override
  State<DeleteAccountConfirmScreen> createState() =>
      _DeleteAccountConfirmScreenState();
}

class _DeleteAccountConfirmScreenState
    extends State<DeleteAccountConfirmScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _analytics = Analytics();
  final FocusNode _codeFocus = FocusNode();
  String? phoneNumber;
  String? countryCode;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeleteAccountConfirmCubit, DeleteAccountConfirmState>(
      listener: (context, state) {
        _phoneController.text = state.phoneNumber;
        _emailController.text = state.email;
        switch (state.status) {
          case AuthStatus.authorized:
          case AuthStatus.phoneCodeConfirmed:
            Navigator.of(context).pop(true);
            break;
          case AuthStatus.phoneCodeSent:
            _codeFocus.requestFocus();
            break;
          case AuthStatus.unauthorized:
            _analytics.logEvent(name: Metric.eventAuthError);
            break;
          case AuthStatus.phoneCodeInvalid:
            _codeController.clear();
            _codeFocus.requestFocus();
            break;
          default:
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).delete_account_confirm_title),
          ),
          body: _getContent(state),
        );
      },
    );
  }

  Widget _getContent(DeleteAccountConfirmState state) {
    switch (state.status) {
      case AuthStatus.initial:
      case AuthStatus.loadingEmail:
      case AuthStatus.phoneCodeRequested:
      case AuthStatus.authorized:
      case AuthStatus.unauthorized:
        return _getLoginContent(state);
      case AuthStatus.phoneCodeSent:
      case AuthStatus.phoneCodeConfirmed:
      case AuthStatus.phoneCodeInvalid:
      case AuthStatus.phoneCodeSentByUser:
        return _getPhoneConfirmContent(state);
      case AuthStatus.phoneAuthError:
        return _getErrorContent(state);
    }
  }

  Widget _getPhoneConfirmContent(DeleteAccountConfirmState state) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Visibility(
            visible: state.status == AuthStatus.phoneCodeInvalid,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                S.of(context).phone_number_error_invalid_code,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
          Text(
            S.of(context).phone_number_sms_code_headline,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(
            height: Dimens.defaultPadding,
          ),
          TextField(
            controller: _codeController,
            focusNode: _codeFocus,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            autocorrect: false,
            decoration: textFieldDecoration(
                label: S.of(context).phone_number_sms_code_placeholder),
            onChanged: (value) {
              if (value.length == 6) {
                context.read<DeleteAccountConfirmCubit>().confirm(value);
              }
            },
          ),
          const SizedBox(
            height: Dimens.defaultPadding,
          ),
          Visibility(
            visible: state.status == AuthStatus.phoneCodeSentByUser,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLoginContent(DeleteAccountConfirmState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.defaultPadding),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.of(context).delete_account_confirm_headline,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.start,
              ),
              if (state.hasPhoneCredential) ..._getPhoneLoginContent(state),
              const SizedBox(
                height: 24,
              ),
              Visibility(
                visible: state.hasEmailCredential && state.hasPhoneCredential,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: WlColors.textColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: Text(
                        S.of(context).auth_divider,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: WlColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              if (state.hasEmailCredential) ..._getEmailLoginContent(state),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getPhoneLoginContent(DeleteAccountConfirmState state) {
    return [
      const SizedBox(
        height: 12,
      ),
      IntlPhoneField(
        controller: _phoneController,
        decoration: textFieldDecoration(
          label: S.of(context).profile_phone_number,
        ),
        initialCountryCode: Constants.initialCountryCodePhone,
        invalidNumberMessage: S.of(context).phone_number_error_invalid,
        onChanged: (phone) {
          phoneNumber = phone.number;
        },
        onCountryChanged: (country) {
          countryCode = "+${country.dialCode}";
        },
      ),
      const SizedBox(
        height: Dimens.defaultPadding,
      ),
      ElevatedButton(
        onPressed: () {
          if (!_buttonsActive(state)) {
            return;
          }
          _analytics.logEvent(name: Metric.eventAuthPhoneLogin);
          context.read<DeleteAccountConfirmCubit>().loginWithPhone(
                _getPhoneNumber(state),
              );
        },
        child: state.status == AuthStatus.phoneCodeRequested
            ? const ButtonLoading()
            : Text(S.of(context).auth_login),
      ),
    ];
  }

  List<Widget> _getEmailLoginContent(DeleteAccountConfirmState state) {
    return [
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: TextField(
          controller: _emailController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.username],
          autocorrect: false,
          decoration:
              textFieldDecoration(label: S.of(context).auth_email_placeholder),
          onChanged: (value) {
            context.read<DeleteAccountConfirmCubit>().onFocusChanged();
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 12),
        child: TextField(
          controller: _passwordController,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: const [AutofillHints.password],
          obscureText: true,
          autocorrect: false,
          decoration: textFieldDecoration(
              label: S.of(context).auth_password_placeholder),
          onChanged: (value) {
            context.read<DeleteAccountConfirmCubit>().onFocusChanged();
          },
        ),
      ),
      SizedBox(
        height: state.status == AuthStatus.unauthorized ? 4 : 0,
      ),
      Center(
        child: Visibility(
          visible: state.status == AuthStatus.unauthorized,
          child: Text(
            S.of(context).auth_error,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: WlColors.error),
          ),
        ),
      ),
      const SizedBox(
        height: 32,
      ),
      ElevatedButton(
        onPressed: () {
          if (state.status == AuthStatus.loadingEmail) {
            return;
          }
          _analytics.logEvent(name: Metric.eventAuthLogin);
          context.read<DeleteAccountConfirmCubit>().login(
                _emailController.text,
                _passwordController.text,
              );
        },
        child: state.status == AuthStatus.loadingEmail
            ? const ButtonLoading()
            : Text(S.of(context).auth_login),
      ),
      const SizedBox(
        height: 12,
      ),
    ];
  }

  Widget _getErrorContent(DeleteAccountConfirmState state) {
    String error = "";
    String buttonText = "";
    switch (state.phoneConfirmError!) {
      case PhoneConfirmError.invalidPhoneNumber:
        error = S.of(context).phone_number_error_invalid;
        break;
      case PhoneConfirmError.alreadyInUse:
        error = S.of(context).phone_number_error_already_used;
        buttonText = S.of(context).phone_number_action_contact_support;
        break;
      case PhoneConfirmError.timeout:
        error = S.of(context).phone_number_error_expired_code;
        break;
      case PhoneConfirmError.tooManyRequests:
        error = S.of(context).phone_number_error_too_many_tries;
        break;
      case PhoneConfirmError.invalidCode:
      case PhoneConfirmError.alreadyLinked:
      case PhoneConfirmError.unknown:
        error = S.of(context).phone_number_error_generic;
        buttonText = S.of(context).phone_number_action_contact_support;
    }

    return Padding(
      padding: const EdgeInsets.all(Dimens.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            error,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(
            height: Dimens.defaultPadding,
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DeleteAccountConfirmCubit>().retry();
            },
            child: Text(S.of(context).phone_number_action_retry_generic),
          ),
          const SizedBox(
            height: Dimens.defaultPadding,
          ),
          Visibility(
            visible: buttonText.isNotEmpty,
            child: ElevatedButton(
              onPressed: () {
                _codeController.clear();
                _sendEmail();
              },
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }

  String _getPhoneNumber(DeleteAccountConfirmState state) {
    String? countryCode;
    String? phoneNumber;
    countryCode = this.countryCode ?? Constants.initialCountryDialCodePhone;
    phoneNumber = this.phoneNumber ?? state.phoneNumber;
    return countryCode + phoneNumber;
  }

  _sendEmail() {
    Utils.sendSupportEmail(
        subject: S.of(context).phone_number_support_email_subject,
        body: S.of(context).phone_number_support_email_body(
              phoneNumber ?? "",
            ));
  }

  bool _buttonsActive(DeleteAccountConfirmState state) {
    return state.status != AuthStatus.loadingEmail &&
        state.status != AuthStatus.phoneCodeRequested;
  }
}

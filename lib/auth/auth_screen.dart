import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/analytics/metric.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:local/widgets/button_loading.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../environment/app_config.dart';
import '../generated/l10n.dart';
import '../repos/phone_confirm_error.dart';
import '../routes.dart';
import '../theme/decorations.dart';
import '../theme/dimens.dart';
import '../utils.dart';
import '../widgets/dialog_utils.dart';
import 'auth_cubit.dart';
import 'auth_status.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _analytics = Analytics();
  final FocusNode _codeFocus = FocusNode();
  String? phoneNumber;

  @override
  void initState() {
    super.initState();
    _checkAppVersion();
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
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authorized:
          case AuthStatus.phoneCodeConfirmed:
            Navigator.of(context).pushReplacementNamed(Routes.home);
            break;
          case AuthStatus.phoneCodeSent:
            _codeFocus.requestFocus();
            break;
          case AuthStatus.invalidEmailCredentials:
            _analytics.logEvent(name: Metric.eventAuthError);
            break;
          case AuthStatus.phoneCodeInvalid:
            _codeController.clear();
            _codeFocus.requestFocus();
            break;
          case AuthStatus.passwordResetRequested:
            _showInfoDialog(S.of(context).auth_reset_password_success_title,
                S.of(context).auth_reset_password_success_message);
            break;
          case AuthStatus.passwordResetError:
            _showInfoDialog(S.of(context).auth_reset_password_error_title,
                S.of(context).auth_reset_password_error_message);
            break;
          default:
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).auth_title),
          ),
          body: _getContent(state),
        );
      },
    );
  }

  Widget _getContent(AuthState state) {
    switch (state.status) {
      case AuthStatus.initial:
      case AuthStatus.loadingEmail:
      case AuthStatus.phoneCodeRequested:
      case AuthStatus.authorized:
      case AuthStatus.invalidEmailCredentials:
      case AuthStatus.passwordResetRequested:
      case AuthStatus.passwordResetError:
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

  Widget _getPhoneConfirmContent(AuthState state) {
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
                context.read<AuthCubit>().confirm(value);
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
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthCubit>().retry();
              },
              child: Text(S.of(context).generic_back),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLoginContent(AuthState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(Dimens.defaultPadding),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._getPhoneLoginContent(state),
              const SizedBox(
                height: 24,
              ),
              Row(
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
              const SizedBox(
                height: 24,
              ),
              ..._getEmailLoginContent(state),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineSmall,
                    children: [
                      TextSpan(text: S.of(context).terms1),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse(Constants.tcUrl));
                          },
                        text: S.of(context).terms_clickable,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: WlColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getPhoneLoginContent(AuthState state) {
    return [
      Text(
        S.of(context).auth_subtitle,
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.start,
      ),
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
          phoneNumber = phone.completeNumber;
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
          context.read<AuthCubit>().loginWithPhone(
                phoneNumber ?? '',
              );
        },
        child: state.status == AuthStatus.phoneCodeRequested
            ? const ButtonLoading()
            : Text(S.of(context).auth_login),
      ),
    ];
  }

  List<Widget> _getEmailLoginContent(AuthState state) {
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
            context.read<AuthCubit>().onFocusChanged();
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
            context.read<AuthCubit>().onFocusChanged();
          },
        ),
      ),
      SizedBox(
        height: state.status == AuthStatus.invalidEmailCredentials ? 4 : 0,
      ),
      Center(
        child: Visibility(
          visible: state.status == AuthStatus.invalidEmailCredentials,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.of(context).auth_error,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: WlColors.error),
              ),
              const SizedBox(
                height: 4,
              ),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<AuthCubit>()
                      .resetPassword(_emailController.text);
                },
                child: Text(S.of(context).auth_reset_password_button),
              ),
            ],
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
          context.read<AuthCubit>().login(
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
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.register);
        },
        child: Text(S.of(context).auth_register),
      ),
    ];
  }

  Widget _getErrorContent(AuthState state) {
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
              context.read<AuthCubit>().retry();
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

  _sendEmail() {
    Utils.sendSupportEmail(
        subject: S.of(context).phone_number_support_email_subject,
        body: S.of(context).phone_number_support_email_body(
              phoneNumber ?? "",
            ));
  }

  bool _buttonsActive(AuthState state) {
    return state.status != AuthStatus.loadingEmail &&
        state.status != AuthStatus.phoneCodeRequested;
  }

  _showInfoDialog(String title, String content) {
    showPlatformDialog(
        context: context,
        title: title,
        content: content,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthCubit>().retry();
            },
            child: Text(S.of(context).generic_ok),
          ),
        ]);
  }

  _checkAppVersion() async {
    final versionMessage = await AppConfig.checkAppVersion();
    if (versionMessage != null) {
      _analytics.logEvent(name: Metric.eventAppVersionDialog);
      showAppVersionDialog(context: context, message: versionMessage);
    }
  }
}

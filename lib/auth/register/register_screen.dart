import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/auth/register/register_cubit.dart';
import 'package:local/generated/l10n.dart';
import 'package:local/routes.dart';
import 'package:local/theme/decorations.dart';
import 'package:local/theme/dimens.dart';
import 'package:local/widgets/dialog_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../analytics/analytics.dart';
import '../../analytics/metric.dart';
import '../../constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const double textsSpacing = 24;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  String? _emailError;
  String? _passwordError;
  String? _nameError;
  String? _phoneError;
  final _analytics = Analytics();

  @override
  void initState() {
    super.initState();
    _listenForFocusChanges();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _listenForFocusChanges() {
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _isEmailValid(_emailController.text);
      }
    });
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        _isPasswordValid(_passwordController.text);
      }
    });
    _nameFocusNode.addListener(() {
      if (!_nameFocusNode.hasFocus) {
        _isNameValid(_nameController.text);
      }
    });
    _phoneFocusNode.addListener(() {
      if (!_phoneFocusNode.hasFocus) {
        _isPhoneValid(_phoneController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        switch (state.status) {
          case RegisterStatus.initial:
            break;
          case RegisterStatus.success:
            _analytics.logEvent(name: Metric.eventRegisterSuccess);
            Navigator.of(context)
                .pushNamedAndRemoveUntil(Routes.home, (route) => false);
            break;
          case RegisterStatus.failure:
            _analytics.logEvent(name: Metric.eventRegisterError);
            _showRegistrationError();
            break;
          case RegisterStatus.loading:
            // TODO: Handle this case.
            break;
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppBar(
              leading: state.status == RegisterStatus.loading
                  ? const SizedBox()
                  : null,
              title: Text(S.of(context).register_title),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Dimens.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: textsSpacing),
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: textFieldDecoration(
                          label: S.of(context).auth_email_placeholder,
                          error: _emailError),
                    ),
                    const SizedBox(
                      height: textsSpacing,
                    ),
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.next,
                      decoration: textFieldDecoration(
                          label: S.of(context).auth_password_placeholder,
                          error: _passwordError),
                    ),
                    const SizedBox(
                      height: textsSpacing,
                    ),
                    TextField(
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: textFieldDecoration(
                          label: S.of(context).profile_name, error: _nameError),
                    ),
                    const SizedBox(
                      height: textsSpacing,
                    ),
                    TextField(
                      controller: _phoneController,
                      focusNode: _phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.go,
                      decoration: textFieldDecoration(
                          label: S.of(context).profile_phone_number,
                          error: _phoneError),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.headline5,
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
                                  .headline5
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (state.status == RegisterStatus.loading) {
                          return;
                        }
                        _analytics.logEvent(name: Metric.eventAuthRegister);
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (_areFieldsValid()) {
                          context.read<RegisterCubit>().register(
                                email: _emailController.text,
                                password: _passwordController.text,
                                name: _nameController.text,
                                phone: _phoneController.text,
                              );
                        }
                      },
                      child: state.status == RegisterStatus.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(S.of(context).auth_register),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _areFieldsValid() {
    return _isEmailValid(_emailController.text) &&
        _isPasswordValid(_passwordController.text) &&
        _isNameValid(_nameController.text) &&
        _isPhoneValid(_phoneController.text);
  }

  bool _isEmailValid(String email) {
    final emailRegexp = RegExp(Constants.emailRegex);
    if (emailRegexp.hasMatch(email)) {
      setState(() {
        _emailError = null;
      });
      return true;
    } else {
      setState(() {
        _emailError = S.of(context).register_email_error;
      });
      return false;
    }
  }

  bool _isPasswordValid(String password) {
    if (password.length >= 6) {
      setState(() {
        _passwordError = null;
      });
      return true;
    } else {
      setState(() {
        _passwordError = S.of(context).register_password_error;
      });
      return false;
    }
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

  _showRegistrationError() {
    showPlatformDialog(
      context: context,
      title: S.of(context).register_error_title,
      content: S.of(context).register_error_message,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<RegisterCubit>().onDialogClosed();
          },
          child: Text(S.of(context).generic_ok),
        ),
      ],
    );
  }
}

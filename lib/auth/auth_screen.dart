import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/analytics/analytics.dart';
import 'package:local/analytics/metric.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:local/widgets/button_loading.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../generated/l10n.dart';
import '../routes.dart';
import '../theme/decorations.dart';
import '../theme/dimens.dart';
import 'auth_cubit.dart';
import 'auth_status.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({Key? key}) : super(key: key);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _analytics = Analytics();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authorized:
            Navigator.of(context).pushReplacementNamed(Routes.home);
            break;
          case AuthStatus.unauthorized:
            _analytics.logEvent(name: Metric.eventAuthError);
            break;
          case AuthStatus.initial:
          case AuthStatus.loadingEmail:
            // No-op
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).auth_title),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Dimens.defaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 32,
                  ),
                  Text(
                    S.of(context).auth_subtitle,
                    style: Theme.of(context).textTheme.headline4,
                    textAlign: TextAlign.start,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: TextField(
                      controller: _emailController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: textFieldDecoration(
                          label: S.of(context).auth_email_placeholder),
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
                    height: state.status == AuthStatus.unauthorized ? 4 : 0,
                  ),
                  Center(
                    child: Visibility(
                      visible: state.status == AuthStatus.unauthorized,
                      child: Text(
                        S.of(context).auth_error,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            ?.copyWith(color: WlColors.error),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (state.status == AuthStatus.loadingEmail ||
                          state.status == AuthStatus.loadingAnonymously) {
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
                  const SizedBox(
                    height: 44,
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
                          style: Theme.of(context).textTheme.subtitle1,
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
                  ElevatedButton(
                    onPressed: () {
                      if (state.status == AuthStatus.loadingEmail ||
                          state.status == AuthStatus.loadingAnonymously) {
                        return;
                      }
                      _analytics.logEvent(
                          name: Metric.eventAuthLoginAnonymously);
                      context.read<AuthCubit>().loginAnonymously();
                    },
                    child: state.status == AuthStatus.loadingAnonymously
                        ? const ButtonLoading()
                        : Text(S.of(context).auth_anonymous),
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
      },
    );
  }
}

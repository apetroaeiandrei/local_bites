import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/theme/wl_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authorized:
            Navigator.of(context).pushReplacementNamed(Routes.home);
            break;
          case AuthStatus.initial:
            // TODO: Handle this case.
            break;
          case AuthStatus.unauthorized:
            // TODO: Handle this case.
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
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
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
                        decoration: textFieldDecoration(
                            S.of(context).auth_email_placeholder),
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
                            S.of(context).auth_password_placeholder),
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().login(
                              _emailController.text,
                              _passwordController.text,
                            );
                      },
                      child: Text(S.of(context).auth_login),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().register(
                              _emailController.text,
                              _passwordController.text,
                            );
                      },
                      child: Text(S.of(context).auth_register),
                    ),
                    const SizedBox(height: 44,),
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
                          child: Text(S.of(context).auth_divider, style: Theme.of(context).textTheme.subtitle1,),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: WlColors.textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24,),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().loginAnonymously();
                      },
                      child: Text(S.of(context).auth_anonymous),
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

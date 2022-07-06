import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../generated/l10n.dart';
import '../routes.dart';
import '../theme/decorations.dart';
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
              Navigator.of(context).pushReplacementNamed(Routes.admin);
            break;
          case AuthStatus.registeredSuccessfully:
              Navigator.of(context).pushReplacementNamed(Routes.profile);
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
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    Text(
                      S.of(context).auth_header,
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: TextField(
                        controller: _emailController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.emailAddress,
                        decoration: textFieldDecoration(
                            S.of(context).auth_email_placeholder),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
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
                      height: 32,
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

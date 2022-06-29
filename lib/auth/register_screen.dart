import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/auth/register_cubit.dart';

import '../generated/l10n.dart';
import '../theme/decorations.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({Key? key}) : super(key: key);
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {},
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
                      S.of(context).auth_register,
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.name,
                        decoration: textFieldDecoration(S.of(context).name),
                      ),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration:
                            textFieldDecoration(S.of(context).phone_number),
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<RegisterCubit>().register(
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

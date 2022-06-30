import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/auth/profile_cubit.dart';

import '../generated/l10n.dart';
import '../theme/decorations.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
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
                      S.of(context).user_details,
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.name,
                        decoration: textFieldDecoration(S.of(context).name),
                        controller: _nameController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.streetAddress,
                        decoration: textFieldDecoration(S.of(context).address),
                        controller: _addressController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration:
                            textFieldDecoration(S.of(context).phone_number),
                        controller: _phoneController,
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileCubit>().setUserDetails(
                          _nameController.text,
                          _addressController.text,
                          _phoneController.text
                        );
                      },
                      child: Text(S.of(context).save),
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

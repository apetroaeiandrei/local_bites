import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/profile/profile_cubit.dart';
import 'package:local/profile/profile_state.dart';

import '../generated/l10n.dart';
import '../theme/decorations.dart';
import '../theme/dimens.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: const SizedBox(),
            title: Text(
              S.of(context).profile_user_details,
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Dimens.defaultPadding),
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
                      decoration:
                          textFieldDecoration(S.of(context).profile_name),
                      controller: _nameController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: textFieldDecoration(
                          S.of(context).profile_phone_number),
                      controller: _phoneController,
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileCubit>().setUserDetails(
                          _nameController.text, _phoneController.text);
                    },
                    child: Text(S.of(context).generic_save),
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

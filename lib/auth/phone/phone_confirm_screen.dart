import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/auth/phone/phone_confirm_cubit.dart';

class PhoneConfirmScreen extends StatefulWidget {
  const PhoneConfirmScreen({Key? key}) : super(key: key);

  @override
  State<PhoneConfirmScreen> createState() => _PhoneConfirmScreenState();
}

class _PhoneConfirmScreenState extends State<PhoneConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneConfirmCubit, PhoneConfirmState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Phone Confirm"),
          ),
          body: const Center(
            child: Text("Phone Confirm"),
          ),
        );
      },
    );
  }
}

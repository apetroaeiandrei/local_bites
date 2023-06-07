import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/vouchers/vouchers_cubit.dart';

import '../routes.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({Key? key}) : super(key: key);

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VouchersCubit, VouchersState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Vouchers"),
          ),
          body: Center(
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(Routes.phone);
                },
                child: const Text("Confirm phone")),
          ),
        );
      },
    );
  }
}

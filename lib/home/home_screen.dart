import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/home/home_cubit.dart';

import '../routes.dart';
import 'home_status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (BuildContext context, HomeState state) {
        switch (state.status) {
          case HomeStatus.inCompleted:
            Navigator.of(context).pushReplacementNamed(Routes.profile);
            break;
          case HomeStatus.initial:
            break;
          case HomeStatus.completed:
            break;
        }
      },
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Text("home"),
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

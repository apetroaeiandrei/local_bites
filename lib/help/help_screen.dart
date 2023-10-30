import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/theme/dimens.dart';

import '../generated/l10n.dart';
import 'help_cubit.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).help_screen_title),
      ),
      body: BlocBuilder<HelpCubit, HelpState>(
        builder: (context, state) {
          return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ExpansionTile(
                  title: Text(item.question),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.defaultPadding,
                        vertical: 8,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.answer,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ],
                );
              });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:local/address/addresses/address_tile.dart';
import 'package:local/address/addresses/addresses_cubit.dart';
import 'package:local/analytics/metric.dart';
import 'package:local/theme/dimens.dart';
import 'package:local/widgets/dialog_utils.dart';

import '../../analytics/analytics.dart';
import '../../generated/l10n.dart';
import '../../routes.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _analytics = Analytics();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddressesCubit, AddressesState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).addresses_title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(Dimens.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  S.of(context).addresses_info,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(
                  height: Dimens.defaultPadding,
                ),
                ElevatedButton(
                  onPressed: () {
                    _analytics.setCurrentScreen(screenName: Routes.address);
                    Navigator.of(context).pushNamed(Routes.address).then(
                        (value) => _analytics.setCurrentScreen(
                            screenName: Routes.addresses));
                  },
                  child: Text(S.of(context).addresses_add),
                ),
                const SizedBox(
                  height: 28,
                ),
                Text(
                  S.of(context).addresses_headline,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Visibility(
                  visible: state.addresses.isEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      S.of(context).addresses_empty,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      bool selected = state.addresses[index].street ==
                              state.selectedAddress?.street &&
                          state.addresses[index].propertyDetails ==
                              state.selectedAddress?.propertyDetails;
                      return InkWell(
                        onTap: () {
                          context
                              .read<AddressesCubit>()
                              .onAddressSelected(state.addresses[index]);
                        },
                        child: Slidable(
                          key: Key(state.addresses[index].street),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  if (selected) {
                                    _showDeleteSelectedDialog();
                                  } else {
                                    context
                                        .read<AddressesCubit>()
                                        .deleteAddress(state.addresses[index]);
                                  }
                                },
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.red,
                                icon: Icons.delete,
                                padding: EdgeInsets.zero,
                                label: S.of(context).address_action_delete,
                              ),
                            ],
                          ),
                          child: AddressTile(
                            address: state.addresses[index],
                            selected: selected,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 10,
                    ),
                    itemCount: state.addresses.length,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteSelectedDialog() {
    _analytics.logEvent(name: Metric.eventAddressTryDeleteSelected);
    showPlatformDialog(
        context: context,
        title: S.of(context).address_delete_current_dialog_title,
        content: S.of(context).address_delete_current_dialog_content,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).generic_ok),
          ),
        ]);
  }
}

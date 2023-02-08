import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local/address/addresses/address_tile.dart';
import 'package:local/address/addresses/addresses_cubit.dart';
import 'package:local/theme/dimens.dart';

import '../../generated/l10n.dart';
import '../../routes.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
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
                    Navigator.of(context).pushNamed(Routes.address);
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
                    itemBuilder: (context, index) => InkWell(
                      onTap: () {
                        context.read<AddressesCubit>().onAddressSelected(state.addresses[index]);
                      },
                      child: AddressTile(
                        address: state.addresses[index],
                        selected: state.addresses[index].street ==
                            state.selectedAddress?.street,
                      ),
                    ),
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
}

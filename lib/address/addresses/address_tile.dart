import 'package:flutter/material.dart';
import 'package:local/address/address_type_extension.dart';
import 'package:models/delivery_address.dart';

class AddressTile extends StatelessWidget {
  const AddressTile({super.key, required this.address, required this.selected});
  final DeliveryAddress address;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.secondary.withOpacity(0.3)
            : theme.cardColor,
        border: Border.all(
          color: selected ? theme.colorScheme.secondary : theme.dividerColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            address.addressType.getIcon(),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  address.addressType.getName(context),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  address.street,
                  style: theme.textTheme.headlineSmall,
                ),
                Text(address.propertyDetails),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

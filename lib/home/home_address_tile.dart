import 'package:flutter/material.dart';
import 'package:local/address/address_type_extension.dart';
import 'package:models/delivery_address.dart';

class HomeAddressTile extends StatelessWidget {
  const HomeAddressTile({Key? key, required this.address}) : super(key: key);
  final DeliveryAddress address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.2),
        border: Border.all(
          color: theme.colorScheme.secondary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            address.addressType.getIcon(),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  address.addressType.getName(context),
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  address.street,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

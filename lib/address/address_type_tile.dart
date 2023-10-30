import 'package:flutter/material.dart';
import 'package:models/delivery_address.dart';

import 'address_type_extension.dart';

class AddressTypeTile extends StatelessWidget {
  const AddressTypeTile({super.key, required this.type, required this.selected});
  final AddressType type;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
            : Theme.of(context).cardColor,
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).dividerColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            type.getIcon(),
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            type.getName(context),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

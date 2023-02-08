import 'package:flutter/material.dart';
import 'package:models/delivery_address.dart';

import '../generated/l10n.dart';

extension AddressTypeExtension on AddressType {
  IconData getIcon() {
    switch (this) {
      case AddressType.home:
        return Icons.home;
      case AddressType.work:
        return Icons.work;
      case AddressType.other:
        return Icons.location_on;
    }
  }

  String getName(BuildContext context) {
    switch (this) {
      case AddressType.home:
        return S.of(context).address_name_home;
      case AddressType.work:
        return S.of(context).address_name_work;
      case AddressType.other:
        return S.of(context).address_name_other;
    }
  }
}

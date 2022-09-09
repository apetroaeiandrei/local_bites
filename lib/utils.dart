import 'package:flutter/cupertino.dart';
import 'package:local/generated/l10n.dart';
import 'package:models/order_status.dart';

import 'constants.dart';

class Utils {
  static bool useEnStrings(BuildContext context) {
    Locale phoneLocale = Localizations.localeOf(context);
    return phoneLocale.languageCode != Constants.targetLanguageCode;
  }
}

extension OrderStatusExtension on OrderStatus {
  String toUserString(BuildContext context) {
    switch (this) {
      case OrderStatus.pending:
        return S.of(context).order_mini_status_pending;
      case OrderStatus.cooking:
        return S.of(context).order_mini_status_cooking;
      case OrderStatus.readyForDelivery:
        return S.of(context).order_mini_status_ready_for_delivery;
      case OrderStatus.inDelivery:
        return S.of(context).order_mini_status_in_delivery;
      case OrderStatus.completed:
        return S.of(context).order_mini_status_completed;
      case OrderStatus.cancelled:
        return S.of(context).order_mini_status_canceled;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local/generated/l10n.dart';
import 'package:local/theme/wl_colors.dart';
import 'package:models/order_status.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'constants.dart';
import 'img.dart';

class Utils {
  static bool useEnStrings(BuildContext context) {
    Locale phoneLocale = Localizations.localeOf(context);
    return phoneLocale.languageCode != Constants.targetLanguageCode;
  }

  static void launchCall(String phoneNumber) async {
    final url = "tel:$phoneNumber";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
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

  String toLottieResource() {
    switch (this) {
      case OrderStatus.pending:
        return Img.lottiePendingFood;
      case OrderStatus.cooking:
        return Img.lottiePreparingFood;
      case OrderStatus.readyForDelivery:
        return Img.lottieReadyForDelivery;
      case OrderStatus.inDelivery:
        return Img.lottieDeliveringFood;
      case OrderStatus.completed:
        return Img.lottieDeliveredFood;
      case OrderStatus.cancelled:
        return Img.lottieCancelledFood;
    }
  }

  Color toTextColor() {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.cooking:
        return WlColors.primary;
      case OrderStatus.readyForDelivery:
        return Colors.orangeAccent;
      case OrderStatus.inDelivery:
        return WlColors.notificationGreen;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

extension DateUtils on DateTime {
  String toUserString() {
    return DateFormat.MMMd().format(this) + " " + DateFormat.Hm().format(this);
  }
}

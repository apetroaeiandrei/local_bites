import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
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

  static sendSupportEmail({
    required String subject,
    required String body,
  }) async {
    final Email email = Email(
      body: body,
      subject: subject,
      recipients: [Constants.supportEmail],
      cc: [],
      bcc: [],
      isHTML: false,
    );
    await FlutterEmailSender.send(email);
  }

  /// Mostly focused on RO phone numbers
  static String formatPhoneNumberForIntl(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return phoneNumber;
    }
    if (phoneNumber.startsWith(Constants.initialCountryDialCodePhone)) {
      phoneNumber =
          phoneNumber.substring(Constants.initialCountryDialCodePhone.length);
    } else if (phoneNumber.startsWith('0')) {
      phoneNumber = phoneNumber.substring(1);
    }
    return phoneNumber;
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
      case OrderStatus.readyToPickup:
        return S.of(context).order_mini_status_ready_for_pickup;
    }
  }

  String toLottieResource() {
    switch (this) {
      case OrderStatus.pending:
        return Img.lottiePendingFood;
      case OrderStatus.cooking:
        return Img.lottiePreparingFood;
      case OrderStatus.readyToPickup:
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
        return Colors.orangeAccent;
      case OrderStatus.cooking:
      case OrderStatus.readyForDelivery:
      case OrderStatus.readyToPickup:
      case OrderStatus.inDelivery:
      case OrderStatus.completed:
        return WlColors.secondary;
      case OrderStatus.cancelled:
        return WlColors.error;
    }
  }
}

extension DateUtils on DateTime {
  String toUserString() {
    return "${DateFormat.MMMd().format(this)} ${DateFormat.Hm().format(this)}";
  }
}

Widget defaultFoodImage() => Image.asset(
      Img.foodPlaceholder,
      fit: BoxFit.cover,
    );

Widget defaultFoodDetailsImage() => Image.asset(
  Img.genericFood,
  fit: BoxFit.cover,
);


Widget defaultRestaurantImage() => Image.asset(
      Img.restaurantPlaceholder,
      fit: BoxFit.cover,
    );

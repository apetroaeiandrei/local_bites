import 'package:flutter/cupertino.dart';

import 'constants.dart';


class Utils {

  static bool useEnStrings(BuildContext context) {
    Locale phoneLocale = Localizations.localeOf(context);
    return phoneLocale.languageCode != Constants.targetLanguageCode;
  }
}

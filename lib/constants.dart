abstract class Constants {
  static const String initialCountryCodePhone = "RO";
  static const String initialCountryDialCodePhone = "+40";
  static const String targetLanguageCode = "ro";
  static const String labelsSeparator = ',';
  static const String tcUrl = "https://local-restaurants.ro/#/tc";
  static const String supportEmail = "contact.localbites@gmail.com";
  static const String emailRegex =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";

  //Phone regex: starts with 07, has a total of 10 digits
  static String phoneRegex = r'^07\d{8}$';

  static String googlePlayUrl = "market://details?id=com.kotsukotsu.local";
  static String appStoreUrl =
      "https://apps.apple.com/us/app/local-bites/id1658342286";

  static int deliveryEtaErrorDefault = 10;
  static int deliveryPriceErrorDefault = 10;
  static int deliveryPriceStart = 3;
  static int deliveryPricePerKm = 2;

  static String directionsApiKey = 'DIRECTIONS_API_KEY';

}

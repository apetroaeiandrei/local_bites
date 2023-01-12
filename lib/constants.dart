abstract class Constants {
  static const String targetLanguageCode = "ro";
  static const String labelsSeparator = ',';
  static const String tcUrl = "https://local-restaurants.ro/#/tc";
  static const String emailRegex = r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  //Phone regex: starts with 07, has a total of 10 digits
  static String phoneRegex = r'^07\d{8}$';
}
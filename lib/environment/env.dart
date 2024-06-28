// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'keys.dev.env')
abstract class EnvDev {
  @EnviedField(varName: 'STRIPE_KEY', defaultValue: 'test_', obfuscate: true)
  static final String stripeKey = _EnvDev.stripeKey;
  @EnviedField(varName: 'STRIPE_MERCHANT_ID', defaultValue: 'test_', obfuscate: true)
  static final String stripeMerchantIdentifier = _EnvDev.stripeMerchantIdentifier;
  @EnviedField(varName: 'CURRENCY', defaultValue: 'currency', obfuscate: false)
  static const String currency = _EnvDev.currency;
  @EnviedField(varName: 'COUNTRY_CODE', defaultValue: '_', obfuscate: false)
  static const String countryCode = _EnvDev.countryCode;
}

@Envied(path: 'keys.env')
abstract class EnvProd {
  @EnviedField(varName: 'STRIPE_KEY', defaultValue: 'test_', obfuscate: true)
  static final String stripeKey = _EnvProd.stripeKey;
  @EnviedField(varName: 'STRIPE_MERCHANT_ID', defaultValue: 'test_', obfuscate: true)
  static final String stripeMerchantIdentifier = _EnvDev.stripeMerchantIdentifier;
  @EnviedField(varName: 'CURRENCY', defaultValue: 'currency', obfuscate: false)
  static const String currency = _EnvProd.currency;
  @EnviedField(varName: 'COUNTRY_CODE', defaultValue: '_', obfuscate: false)
  static const String countryCode = _EnvDev.countryCode;
}
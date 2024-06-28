// lib/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'keys.dev.env')
abstract class EnvDev {
  @EnviedField(varName: 'STRIPE_KEY', defaultValue: 'test_', obfuscate: true)
  static final String stripeKey = _EnvDev.stripeKey;
  @EnviedField(varName: 'STRIPE_MERCHANT_ID', defaultValue: 'test_', obfuscate: true)
  static final String stripeMerchantIdentifier = _EnvDev.stripeMerchantIdentifier;
  @EnviedField(varName: 'SUPPORT_PHONE', defaultValue: 'test_', obfuscate: false)
  static const String supportPhone = _EnvDev.supportPhone;
}

@Envied(path: 'keys.env')
abstract class EnvProd {
  @EnviedField(varName: 'STRIPE_KEY', defaultValue: 'test_', obfuscate: true)
  static final String stripeKey = _EnvProd.stripeKey;
  @EnviedField(varName: 'STRIPE_MERCHANT_ID', defaultValue: 'test_', obfuscate: true)
  static final String stripeMerchantIdentifier = _EnvDev.stripeMerchantIdentifier;
  @EnviedField(varName: 'SUPPORT_PHONE', defaultValue: 'test_', obfuscate: false)
  static const String supportPhone = _EnvProd.supportPhone;
}
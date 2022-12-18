import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local/environment/prod_firebase_options.dart';

import 'dev_firebase_options.dart';

class AppConfig {
  static const String flavorDev = 'dev';
  static const String flavorProd = 'prod';

  static Future<void> init() async {
    final flavor =
        await const MethodChannel('flavor').invokeMethod<String>('getFlavor');

    await Firebase.initializeApp(
      options: flavor == flavorProd
          ? ProdFirebaseOptions.currentPlatform
          : DevFirebaseOptions.currentPlatform,
    );
    await _initAppCheck(flavor == flavorProd);
    _initCrashlytics();
  }

  static _initAppCheck(bool isProd) async {
    await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: 'recaptcha-v3-site-key',
      androidProvider:
          isProd ? AndroidProvider.playIntegrity : AndroidProvider.debug,
    );
  }

  static _initCrashlytics() {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
}

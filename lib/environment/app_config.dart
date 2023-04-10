import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:local/environment/prod_firebase_options.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'dev_firebase_options.dart';

class AppConfig {
  static const String flavorDev = 'dev';
  static const String flavorProd = 'prod';
  static bool isProd = false;

  static Future<void> init() async {
    final flavor =
        await const MethodChannel('flavor').invokeMethod<String>('getFlavor');
    isProd = flavor == flavorProd;

    await Firebase.initializeApp(
      options: isProd
          ? ProdFirebaseOptions.currentPlatform
          : DevFirebaseOptions.currentPlatform,
    );
    await _initAppCheck();
    _initCrashlytics();
    _initStripe();
  }

  static _initAppCheck() async {
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

  static Future<String?> checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final appVersion =
        await FirebaseFirestore.instance.collection("version").doc("app").get();
    final firebaseVersionCode =
        int.parse(appVersion.data()?["versionCode"] as String);
    final appVersionCode = int.parse(packageInfo.buildNumber);

    if (firebaseVersionCode > appVersionCode) {
      return appVersion.data()?["message"];
    }
    return null;
  }

  static Future<void> _initStripe() async {
    Stripe.publishableKey = "pk_test_STRIPE";
    Stripe.merchantIdentifier = "STRIPE_MERCHANT_ID";
    await Stripe.instance.applySettings();
  }
}

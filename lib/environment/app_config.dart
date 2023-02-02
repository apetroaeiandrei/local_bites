import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
   // await _initFCM();
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

  static _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    String? token = await messaging.getToken();
    print('User granted permission: ${settings.authorizationStatus}');
    print('FCM TOKEN: $token');

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });

    //todo: remove this
    // subscribe to topic on each app start-up
    //await FirebaseMessaging.instance.subscribeToTopic('weather');
    //await FirebaseMessaging.instance.unsubscribeFromTopic('weather');

  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}
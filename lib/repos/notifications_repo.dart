import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local/repos/user_repo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../environment/app_config.dart';

class NotificationsRepo {
  static const String notificationTopic = 'topic_';
  static const String topicPromo = 'promo';
  static const String sharedPrefsTokenTimestamp = 'last_token_timestamp';
  static const String vouchersChannelId = 'vouchers_notifications';
  static const String vouchersChannelName = 'Vouchere';

  static NotificationsRepo? _instance;
  final UserRepo _userRepo;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationsRepo._privateConstructor(this._userRepo);

  factory NotificationsRepo(UserRepo userRepo) {
    _instance ??= NotificationsRepo._privateConstructor(userRepo);
    return _instance!;
  }

  static const AndroidNotificationChannel pushVouchersChannel =
      AndroidNotificationChannel(
    vouchersChannelId,
    vouchersChannelName,
    importance: Importance.defaultImportance,
  );

  Future<bool> registerNotifications() async {
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

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: false,
      sound: true,
    );

    String? token = await messaging.getToken();
    if (!AppConfig.isProd) {
      String? userID = FirebaseAuth.instance.currentUser?.uid;
      FirebaseFirestore.instance
          .collection('tokens')
          .doc(userID)
          .set({'token': token});
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(notificationTopic + topicPromo)) {
      await subscribeToTopic(topicPromo);
    }

    _initLocalNotificationsPlugin();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  _initLocalNotificationsPlugin() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(pushVouchersChannel);
  }

  updateFcmToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(sharedPrefsTokenTimestamp);
    final lastRefreshed = DateTime.parse(dateString ?? '2000-01-01');
    final now = DateTime.now();
    if (now.difference(lastRefreshed).inDays > 7) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      await _userRepo.updateUserDetails(fcmToken: token);
      await prefs.setString(
          sharedPrefsTokenTimestamp, DateTime.now().toString());
    }
  }

  subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(notificationTopic + topic, true);
  }

  unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(notificationTopic + topic, false);
  }

  Future<bool> areNotificationsEnabled() async {
    return await Permission.notification.isGranted;
  }

  Future<bool> hasTopicPromo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationTopic + topicPromo) ?? false;
  }

  onLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(sharedPrefsTokenTimestamp);
    prefs.remove(notificationTopic + topicPromo);
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.deleteToken();
  }
}

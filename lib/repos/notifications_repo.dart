import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../environment/app_config.dart';

class NotificationsRepo {
  static const String notificationTopic = 'topic_';
  static const String topicPromo = 'promo';
  static NotificationsRepo? _instance;

  NotificationsRepo._privateConstructor();

  factory NotificationsRepo() {
    _instance ??= NotificationsRepo._privateConstructor();
    return _instance!;
  }

  Future<bool> registerNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
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

    if (!AppConfig.isProd) {
      String? token = await messaging.getToken();
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
    return settings.authorizationStatus == AuthorizationStatus.authorized;
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
}

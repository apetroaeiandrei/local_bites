import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static late FirebaseAnalytics _firebaseAnalytics;
  static Analytics? instance;

  factory Analytics() {
    instance ??= Analytics._privateConstructor();
    return instance!;
  }

  static _privateConstructor() {
    _firebaseAnalytics = FirebaseAnalytics.instance;
  }

  void logEvent({required String name}) {
    _firebaseAnalytics.logEvent(name: name);
  }

  void logEventWithParams({
    required String name,
    required Map<String, Object?> parameters,
  }) {
    _firebaseAnalytics.logEvent(name: name, parameters: parameters);
  }

  void setCurrentScreen({required String screenName}) {
    _firebaseAnalytics.setCurrentScreen(screenName: screenName);
  }

  void setUserId(String? id) {
    _firebaseAnalytics.setUserId(id: id);
  }
}

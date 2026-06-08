import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  static const String campusTopic = 'campus_notifications';

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    try {
      await messaging.subscribeToTopic(campusTopic);
      debugPrint('[NOTIFICATION] FCM topic actif: $campusTopic');
    } catch (error) {
      debugPrint('[NOTIFICATION] FCM topic indisponible: $error');
    }

    final token = await messaging.getToken();
    debugPrint('[NOTIFICATION] FCM token: ${token ?? 'absent'}');
  }

  static Future<void> init(String userId) async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'fcmToken': token}, SetOptions(merge: true));
      debugPrint('[NOTIFICATION] FCM token enregistre pour user: $userId');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'fcmToken': newToken}, SetOptions(merge: true));
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/core/services/local_notification_service.dart';
import 'package:flutter_application_2/features/schedule/domain/entities/course_entity.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
    );
  }

  static Future<void> createCourseNotification(CourseEntity course) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      "title": "Nouveau cours",
      "body": "${course.title} ajouté en salle ${course.room}",
      "createdAt": Timestamp.now(),
      "type": 0,
      "isRead": false,
    });
  }

  static Future<void> scheduleReminder(CourseEntity course) async {
    final diff = course.startTime.difference(DateTime.now());

    if (diff.inMinutes > 0 && diff.inMinutes <= 10) {
      LocalNotificationService.showReminder(course);
    }
  }

  static Future<void> initAppReminders() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('courses').get();

    for (final doc in snapshot.docs) {
      final course = CourseEntity.fromMap(doc.data(), doc.id);
      scheduleReminder(course);
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (Platform.isLinux) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'campuspulse_channel',
      'CampusPulse Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_2/core/services/hive_service.dart';
import 'package:flutter_application_2/core/services/local_notification_service.dart';
import 'package:flutter_application_2/features/schedule/domain/entities/course_entity.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  Future<void> initialize() async {
    await LocalNotificationService.init();
  }

  static Future<bool> _notificationsEnabled() async {
    try {
      return HiveService.getSettingsBox()
              .get(HiveService.notificationsEnabledKey, defaultValue: true)
          as bool;
    } on HiveError {
      await HiveService.init();
      return HiveService.getSettingsBox()
              .get(HiveService.notificationsEnabledKey, defaultValue: true)
          as bool;
    } catch (_) {
      return true;
    }
  }

  static Future<void> createCourseNotification(CourseEntity course) async {
    if (await _notificationsEnabled()) {
      await LocalNotificationService.showCourseAdded(course);
    }

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

    if (diff.inMinutes > 0 && diff.inMinutes <= 10 &&
        await _notificationsEnabled()) {
      await LocalNotificationService.showReminder(course);
    }
  }

  static Future<void> initAppReminders() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('courses').get();

    for (final doc in snapshot.docs) {
      final course = CourseEntity.fromMap(doc.data(), doc.id);
      await scheduleReminder(course);
    }
  }
}


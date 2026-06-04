import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/schedule/domain/entities/course_entity.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);
  }

  static Future<void> showReminder(CourseEntity course) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      course.id.hashCode,
      '⏰ Rappel cours',
      '${course.title} commence bientôt',
      details,
    );
  }
}

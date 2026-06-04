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

  static Future<void> showCourseAdded(CourseEntity course) async {
    const androidDetails = AndroidNotificationDetails(
      'course_added_channel',
      'Nouveaux cours',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Nouveau cours disponible',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      course.id.hashCode ^ 0xCAFE,
      'Nouveau cours ajouté',
      '${course.title} en salle ${course.room}',
      details,
    );
  }

  static Future<void> showRemoteNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'remote_message_channel',
      'Messages de service',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Nouveau message',
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
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

// lib/core/services/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String scheduleBox = 'schedule_box';
  static const String notificationsBox = 'notifications_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(scheduleBox);
    await Hive.openBox(notificationsBox);
  }

  static Box getScheduleBox() => Hive.box(scheduleBox);
  static Box getNotificationsBox() => Hive.box(notificationsBox);
}
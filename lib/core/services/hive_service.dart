// lib/core/services/hive_service.dart

import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String scheduleBox = 'schedule_box';
  static const String notificationsBox = 'notifications_box';
  static const String settingsBox = 'settings_box';

  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String darkModeEnabledKey = 'dark_mode_enabled';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(scheduleBox);
    await Hive.openBox(notificationsBox);
    await Hive.openBox(settingsBox);
  }

  static Box getScheduleBox() => Hive.box(scheduleBox);
  static Box getNotificationsBox() => Hive.box(notificationsBox);
  static Box getSettingsBox() => Hive.box(settingsBox);
}
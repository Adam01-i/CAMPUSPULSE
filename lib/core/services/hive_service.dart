import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String scheduleBox = 'schedule_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(scheduleBox);
  }

  static Box getScheduleBox() {
    return Hive.box(scheduleBox);
  }
}

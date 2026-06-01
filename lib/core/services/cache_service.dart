import 'package:hive/hive.dart';

import 'hive_service.dart';

class CacheService {
  final Box _box = HiveService.getScheduleBox();

  Future<void> saveScheduleTitle(String title) async {
    await _box.put('schedule_title', title);
  }

  String? getScheduleTitle() {
    return _box.get('schedule_title');
  }
}

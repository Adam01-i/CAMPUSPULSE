// lib/features/notifications/data/datasources/notification_local_datasource_impl.dart

import 'package:hive/hive.dart';
import '../models/notification_model.dart';
import 'notification_local_datasource.dart';

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  static const String boxName = 'notifications_box';

  Box get _box => Hive.box(boxName);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final maps = _box.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final notifications = maps.map(NotificationModel.fromMap).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return notifications;
  }

  @override
  Future<void> saveNotification(NotificationModel model) async {
    await _box.put(model.id, model.toMap());
  }

  @override
  Future<void> updateNotification(NotificationModel model) async {
    await _box.put(model.id, model.toMap());
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> markAllAsRead() async {
    final keys = _box.keys.toList();
    for (final key in keys) {
      final raw = _box.get(key);
      if (raw != null) {
        final map = Map<String, dynamic>.from(raw as Map);
        map['isRead'] = true;
        await _box.put(key, map);
      }
    }
  }
}

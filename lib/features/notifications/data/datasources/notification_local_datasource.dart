// lib/features/notifications/data/datasources/notification_local_datasource.dart

import '../models/notification_model.dart';

abstract class NotificationLocalDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> saveNotification(NotificationModel model);
  Future<void> updateNotification(NotificationModel model);
  Future<void> deleteNotification(String id);
  Future<void> markAllAsRead();
}

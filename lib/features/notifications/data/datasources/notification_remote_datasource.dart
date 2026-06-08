import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> saveNotification(NotificationModel model);
  Future<void> updateNotification(NotificationModel model);
  Future<void> deleteNotification(String id);
  Future<void> markAllAsRead();
}

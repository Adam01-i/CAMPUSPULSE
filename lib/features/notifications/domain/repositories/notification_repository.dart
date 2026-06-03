// lib/features/notifications/domain/repositories/notification_repository.dart

import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> addNotification(NotificationEntity notification);
  Future<void> deleteNotification(String id);
}

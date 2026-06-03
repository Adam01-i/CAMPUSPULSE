// lib/features/notifications/data/repositories/notification_repository_impl.dart

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl(this.localDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() =>
      localDataSource.getNotifications();

  @override
  Future<void> markAsRead(String id) async {
    final notifications = await localDataSource.getNotifications();
    final notif = notifications.firstWhere((n) => n.id == id);
    final updated = NotificationModel.fromEntity(notif.copyWith(isRead: true));
    await localDataSource.updateNotification(updated);
  }

  @override
  Future<void> markAllAsRead() => localDataSource.markAllAsRead();

  @override
  Future<void> addNotification(NotificationEntity notification) =>
      localDataSource.saveNotification(
          NotificationModel.fromEntity(notification));

  @override
  Future<void> deleteNotification(String id) =>
      localDataSource.deleteNotification(id);
}

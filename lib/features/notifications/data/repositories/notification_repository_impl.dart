// lib/features/notifications/data/repositories/notification_repository_impl.dart

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() {
    return remoteDataSource.getNotifications();
  }

  @override
  Future<void> markAsRead(String id) async {
    final notifications = await remoteDataSource.getNotifications();
    final notif = notifications.firstWhere((n) => n.id == id);

    final updated = NotificationModel.fromEntity(
      notif.copyWith(isRead: true),
    );

    await remoteDataSource.updateNotification(updated);
  }

  @override
  Future<void> markAllAsRead() {
    return remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> addNotification(NotificationEntity notification) {
    return remoteDataSource.saveNotification(
      NotificationModel.fromEntity(notification),
    );
  }

  @override
  Future<void> deleteNotification(String id) {
    return remoteDataSource.deleteNotification(id);
  }
}

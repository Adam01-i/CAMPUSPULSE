// lib/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart

import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationRepository repository;
  MarkAllNotificationsReadUseCase(this.repository);
  Future<void> call() => repository.markAllAsRead();
}

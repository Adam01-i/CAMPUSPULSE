// lib/features/notifications/domain/usecases/mark_notification_read_usecase.dart

import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationRepository repository;
  MarkNotificationReadUseCase(this.repository);
  Future<void> call(String id) => repository.markAsRead(id);
}

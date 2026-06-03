// lib/features/notifications/domain/usecases/create_notification_usecase.dart

import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class CreateNotificationUseCase {
  final NotificationRepository repository;
  CreateNotificationUseCase(this.repository);
  Future<void> call(NotificationEntity notification) =>
      repository.addNotification(notification);
}

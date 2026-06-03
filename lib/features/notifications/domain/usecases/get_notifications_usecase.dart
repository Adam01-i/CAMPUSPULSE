// lib/features/notifications/domain/usecases/get_notifications_usecase.dart

import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);
  Future<List<NotificationEntity>> call() => repository.getNotifications();
}

// lib/features/notifications/presentation/controllers/notifications_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/create_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';

class NotificationsController
    extends StateNotifier<AsyncValue<List<NotificationEntity>>> {
  final GetNotificationsUseCase getNotifications;
  final MarkNotificationReadUseCase markRead;
  final MarkAllNotificationsReadUseCase markAllRead;
  final CreateNotificationUseCase createNotification;

  NotificationsController({
    required this.getNotifications,
    required this.markRead,
    required this.markAllRead,
    required this.createNotification,
  }) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      state = const AsyncValue.loading();

      final notifications = await getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshNotifications() async {
    try {
      final notifications = await getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    await markRead(id);
    await refreshNotifications();
  }

  Future<void> markAllAsReadAction() async {
    await markAllRead();
    await refreshNotifications();
  }

  Future<void> addNotification(NotificationEntity notification) async {
    await createNotification(notification);
    await refreshNotifications();
  }

  Future<void> deleteNotification(
      String id, Future<void> Function(String) deleteFromRepo) async {
    await deleteFromRepo(id);
    await refreshNotifications();
  }

  int get unreadCount => state.valueOrNull?.where((n) => !n.isRead).length ?? 0;
}

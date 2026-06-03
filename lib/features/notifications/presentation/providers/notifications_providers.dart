// lib/features/notifications/presentation/providers/notifications_providers.dart

import 'package:flutter_application_2/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notification_local_datasource_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/usecases/create_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../controllers/notifications_controller.dart';

final notificationLocalDataSourceProvider =
    Provider((_) => NotificationLocalDataSourceImpl());

final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepositoryImpl(
    ref.watch(notificationLocalDataSourceProvider),
  ),
);

final getNotificationsUseCaseProvider = Provider(
  (ref) => GetNotificationsUseCase(ref.watch(notificationRepositoryProvider)),
);

final markNotificationReadUseCaseProvider = Provider(
  (ref) =>
      MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider)),
);

final markAllNotificationsReadUseCaseProvider = Provider(
  (ref) => MarkAllNotificationsReadUseCase(
      ref.watch(notificationRepositoryProvider)),
);

final createNotificationUseCaseProvider = Provider(
  (ref) =>
      CreateNotificationUseCase(ref.watch(notificationRepositoryProvider)),
);

final notificationsControllerProvider = StateNotifierProvider<
    NotificationsController,
    AsyncValue<List<NotificationEntity>>>(
  (ref) => NotificationsController(
    getNotifications: ref.watch(getNotificationsUseCaseProvider),
    markRead: ref.watch(markNotificationReadUseCaseProvider),
    markAllRead: ref.watch(markAllNotificationsReadUseCaseProvider),
    createNotification: ref.watch(createNotificationUseCaseProvider),
  ),
);

/// Compteur de non-lues pour le badge nav
final unreadCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsControllerProvider);
  return state.valueOrNull
          ?.where((n) => !n.isRead)
          .length ??
      0;
});

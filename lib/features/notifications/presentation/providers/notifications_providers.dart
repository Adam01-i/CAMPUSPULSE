import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notification_remote_datasource_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/usecases/create_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../controllers/notifications_controller.dart';

/// DATA SOURCE
final notificationRemoteDataSourceProvider = Provider(
  (ref) => NotificationRemoteDataSourceImpl(
    FirebaseFirestore.instance,
  ),
);

/// REPOSITORY
final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
  ),
);

/// USECASES
final getNotificationsUseCaseProvider = Provider(
  (ref) => GetNotificationsUseCase(
    ref.watch(notificationRepositoryProvider),
  ),
);

final markNotificationReadUseCaseProvider = Provider(
  (ref) => MarkNotificationReadUseCase(
    ref.watch(notificationRepositoryProvider),
  ),
);

final markAllNotificationsReadUseCaseProvider = Provider(
  (ref) => MarkAllNotificationsReadUseCase(
    ref.watch(notificationRepositoryProvider),
  ),
);

final createNotificationUseCaseProvider = Provider(
  (ref) => CreateNotificationUseCase(
    ref.watch(notificationRepositoryProvider),
  ),
);

/// CONTROLLER
final notificationsControllerProvider = StateNotifierProvider<
    NotificationsController, AsyncValue<List<NotificationEntity>>>(
  (ref) {
    return NotificationsController(
      getNotifications: ref.watch(getNotificationsUseCaseProvider),
      markRead: ref.watch(markNotificationReadUseCaseProvider),
      markAllRead: ref.watch(markAllNotificationsReadUseCaseProvider),
      createNotification: ref.watch(createNotificationUseCaseProvider),
    );
  },
);

final notificationsStreamProvider = StreamProvider<List<NotificationEntity>>(
  (ref) {
    return ref.watch(notificationRemoteDataSourceProvider).watchNotifications();
  },
);

final unreadCountProvider = Provider<int>((ref) {
  final state = ref.watch(notificationsStreamProvider);

  return state.maybeWhen(
    data: (list) => list.where((n) => n.isRead == false).length,
    orElse: () => 0,
  );
});

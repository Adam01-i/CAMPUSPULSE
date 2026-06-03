// lib/features/schedule/presentation/controllers/schedule_notification_bridge.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../domain/entities/course_entity.dart';

/// Pont entre les événements Schedule et le module Notifications.
/// À appeler depuis ScheduleController lors de mutations.
class ScheduleNotificationBridge {
  final Ref _ref;
  const ScheduleNotificationBridge(this._ref);

  Future<void> notifyCourseAdded(CourseEntity course) async {
    await _add(NotificationEntity(
      id: const Uuid().v4(),
      title: 'Nouveau cours ajouté',
      body: '${course.title} — Salle ${course.room}',
      createdAt: DateTime.now(),
      type: NotificationType.newCourse,
    ));
  }

  Future<void> notifyCourseCancelled(CourseEntity course) async {
    await _add(NotificationEntity(
      id: const Uuid().v4(),
      title: 'Cours annulé',
      body: '${course.title} a été annulé',
      createdAt: DateTime.now(),
      type: NotificationType.courseCancelled,
    ));
  }

  Future<void> notifyRoomChanged(
      CourseEntity course, String newRoom) async {
    await _add(NotificationEntity(
      id: const Uuid().v4(),
      title: 'Changement de salle',
      body: '${course.title} déplacé vers $newRoom',
      createdAt: DateTime.now(),
      type: NotificationType.roomChanged,
    ));
  }

  Future<void> notifyReminder(CourseEntity course) async {
    await _add(NotificationEntity(
      id: const Uuid().v4(),
      title: 'Rappel de cours',
      body:
          'Votre cours ${course.title} commence dans 30 minutes',
      createdAt: DateTime.now(),
      type: NotificationType.reminder,
    ));
  }

  Future<void> _add(NotificationEntity entity) async {
    await _ref
        .read(notificationsControllerProvider.notifier)
        .addNotification(entity);
  }
}

final scheduleNotificationBridgeProvider =
    Provider((ref) => ScheduleNotificationBridge(ref));
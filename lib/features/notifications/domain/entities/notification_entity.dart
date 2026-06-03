// lib/features/notifications/domain/entities/notification_entity.dart

enum NotificationType {
  newCourse,
  roomChanged,
  courseCancelled,
  reminder,
  admin,
}

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        title: title,
        body: body,
        createdAt: createdAt,
        type: type,
        isRead: isRead ?? this.isRead,
      );
}

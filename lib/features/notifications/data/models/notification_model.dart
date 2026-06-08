import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.createdAt,
    required super.type,
    super.isRead,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    DateTime parseCreatedAt(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    NotificationType parseType(dynamic value) {
      if (value is int && value >= 0 && value < NotificationType.values.length) {
        return NotificationType.values[value];
      }
      if (value is String) {
        return NotificationType.values.firstWhere(
          (type) => type.name == value,
          orElse: () => NotificationType.admin,
        );
      }
      return NotificationType.admin;
    }

    return NotificationModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      createdAt: parseCreatedAt(map['createdAt']),
      type: parseType(map['type']),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': Timestamp.fromDate(createdAt),
        'type': type.name,
        'isRead': isRead,
      };

  factory NotificationModel.fromEntity(NotificationEntity entity) =>
      NotificationModel(
        id: entity.id,
        title: entity.title,
        body: entity.body,
        createdAt: entity.createdAt,
        type: entity.type,
        isRead: entity.isRead,
      );
}

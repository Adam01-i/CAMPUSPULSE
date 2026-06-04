import 'package:cloud_firestore/cloud_firestore.dart';

class CourseEntity {
  final String id;
  final String title;
  final String room;
  final String teacher;
  final DateTime startTime;
  final DateTime endTime;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.room,
    required this.teacher,
    required this.startTime,
    required this.endTime,
  });

factory CourseEntity.fromMap(Map<String, dynamic> map, String id) {
  final rawStart = map['start_time'] ?? map['startTime'];
  final rawEnd = map['end_time'] ?? map['endTime'];

  DateTime parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }

    throw FormatException('Format de date invalide : $value');
  }

  return CourseEntity(
    id: id,
    title: map['title'] ?? '',
    room: map['room'] ?? '',
    teacher: map['teacher'] ?? '',
    startTime: parseDate(rawStart),
    endTime: parseDate(rawEnd),
  );
}
}

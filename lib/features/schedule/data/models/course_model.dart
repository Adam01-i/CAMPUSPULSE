import '../../domain/entities/course_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.room,
    required super.teacher,
    required super.startTime,
    required super.endTime,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json, String docId) {
    final rawStart = json['start_time'] ?? json['startTime'];
    final rawEnd = json['end_time'] ?? json['endTime'];

    DateTime parseDateTime(dynamic raw) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is String) {
        final parsed = DateTime.tryParse(raw);
        if (parsed != null) return parsed;
      }

      throw FormatException('Format de date invalide : $raw');
    }

    return CourseModel(
      id: docId,
      title: json['title'] ?? '',
      room: json['room'] ?? '',
      teacher: json['teacher'] ?? '',
      startTime: parseDateTime(rawStart),
      endTime: parseDateTime(rawEnd),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'room': room,
      'teacher': teacher,
      'start_time': Timestamp.fromDate(startTime),
      'end_time': Timestamp.fromDate(endTime),
    };
  }
}
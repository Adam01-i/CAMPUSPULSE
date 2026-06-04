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
    return CourseModel(
      id: docId,
      title: json['title'] ?? '',
      room: json['room'] ?? '',
      teacher: json['teacher'] ?? '',
      startTime: (json['start_time'] as Timestamp).toDate(),
      endTime: (json['end_time'] as Timestamp).toDate(),
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
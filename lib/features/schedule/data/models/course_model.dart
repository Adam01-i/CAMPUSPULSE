import '../../domain/entities/course_entity.dart';

class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.title,
    required super.room,
    required super.teacher,
    required super.startTime,
    required super.endTime,
  });

  factory CourseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CourseModel(
      id: json['id'],
      title: json['title'],
      room: json['room'],
      teacher: json['teacher'],
      startTime: DateTime.parse(
        json['start_time'],
      ),
      endTime: DateTime.parse(
        json['end_time'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'room': room,
      'teacher': teacher,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };
  }
}

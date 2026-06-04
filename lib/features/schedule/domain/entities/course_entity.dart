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
}

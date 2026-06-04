import '../entities/course_entity.dart';

abstract class ScheduleRepository {
  Future<List<CourseEntity>> getCourses();
  Future<void> createCourse(CourseEntity course);
}

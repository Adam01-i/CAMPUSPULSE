import '../models/course_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<CourseModel>> getCourses();
}

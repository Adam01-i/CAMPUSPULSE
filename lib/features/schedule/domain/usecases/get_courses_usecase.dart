import '../entities/course_entity.dart';
import '../repositories/schedule_repository.dart';

class GetCoursesUseCase {
  final ScheduleRepository repository;

  GetCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call() async {
    return await repository.getCourses();
  }
}

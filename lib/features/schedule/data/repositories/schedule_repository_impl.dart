import '../../../../features/schedule/data/models/course_model.dart';

import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;

  ScheduleRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<List<CourseEntity>> getCourses() async {
    return await remoteDataSource.getCourses();
  }

  @override
  Future<void> createCourse(CourseEntity course) async {
    final model = CourseModel(
      id: '',
      title: course.title,
      room: course.room,
      teacher: course.teacher,
      startTime: course.startTime,
      endTime: course.endTime,
    );

    await remoteDataSource.createCourse(model);
  }
}

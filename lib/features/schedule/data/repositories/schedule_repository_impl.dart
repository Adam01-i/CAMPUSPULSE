import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

class ScheduleRepositoryImpl
    implements ScheduleRepository {
  final ScheduleRemoteDataSource
      remoteDataSource;

  ScheduleRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<List<CourseEntity>> getCourses() async {
    return await remoteDataSource.getCourses();
  }
}

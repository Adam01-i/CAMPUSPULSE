import '../../../../core/network/dio_client.dart';
import '../models/course_model.dart';
import 'schedule_remote_datasource.dart';

class ScheduleRemoteDataSourceImpl
    implements ScheduleRemoteDataSource {
  final DioClient dioClient;

  ScheduleRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<CourseModel>> getCourses() async {
    await Future.delayed(
      const Duration(seconds: 1),
    );

    final response = [
      {
        'id': 1,
        'title': 'Architecture Logicielle',
        'room': 'Salle A12',
        'teacher': 'Dr. Gaye',
        'start_time': DateTime.now()
            .toIso8601String(),
        'end_time': DateTime.now()
            .add(const Duration(hours: 2))
            .toIso8601String(),
      },
      {
        'id': 2,
        'title': 'Flutter Avancé',
        'room': 'Salle B05',
        'teacher': 'Mme Diallo',
        'start_time': DateTime.now()
            .add(const Duration(hours: 3))
            .toIso8601String(),
        'end_time': DateTime.now()
            .add(const Duration(hours: 5))
            .toIso8601String(),
      },
    ];

    return response
        .map(
          (json) => CourseModel.fromJson(json),
        )
        .toList();
  }
}

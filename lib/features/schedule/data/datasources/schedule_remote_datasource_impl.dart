import '../../../../core/network/dio_client.dart';
import '../models/course_model.dart';
import 'schedule_remote_datasource.dart';

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
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
        'title': 'Développement Mobile',
        'room': 'A204',
        'teacher': 'M. Ndiaye',
        'start_time':
            DateTime.now().add(const Duration(minutes: 45)).toIso8601String(),
        'end_time':
            DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 2,
        'title': 'Architecture SI',
        'room': 'B105',
        'teacher': 'Mme Diallo',
        'start_time':
            DateTime.now().add(const Duration(hours: 3)).toIso8601String(),
        'end_time':
            DateTime.now().add(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'id': 3,
        'title': 'Sécurité Réseau',
        'room': 'Lab 3',
        'teacher': 'Dr. Gaye',
        'start_time':
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'end_time': DateTime.now()
            .add(const Duration(days: 1, hours: 2))
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

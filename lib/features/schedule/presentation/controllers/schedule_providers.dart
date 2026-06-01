import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/network_provider.dart';
import '../../data/datasources/schedule_remote_datasource.dart';
import '../../data/datasources/schedule_remote_datasource_impl.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/usecases/get_courses_usecase.dart';

final scheduleRemoteDataSourceProvider =
    Provider<ScheduleRemoteDataSource>((ref) {
  final dioClient = ref.watch(
    dioClientProvider,
  );

  return ScheduleRemoteDataSourceImpl(
    dioClient,
  );
});

final scheduleRepositoryProvider =
    Provider((ref) {
  final remoteDataSource = ref.watch(
    scheduleRemoteDataSourceProvider,
  );

  return ScheduleRepositoryImpl(
    remoteDataSource,
  );
});

final getCoursesUseCaseProvider =
    Provider((ref) {
  final repository = ref.watch(
    scheduleRepositoryProvider,
  );

  return GetCoursesUseCase(
    repository,
  );
});

// lib/features/schedule/presentation/controllers/schedule_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/schedule_remote_datasource_impl.dart';
import '../../data/repositories/schedule_repository_impl.dart';
import '../../domain/usecases/get_courses_usecase.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final scheduleRemoteDataSourceProvider =
    Provider((ref) => ScheduleRemoteDataSourceImpl(ref.watch(dioClientProvider)));

final scheduleRepositoryProvider = Provider(
    (ref) => ScheduleRepositoryImpl(ref.watch(scheduleRemoteDataSourceProvider)));

final getCoursesUseCaseProvider =
    Provider((ref) => GetCoursesUseCase(ref.watch(scheduleRepositoryProvider)));
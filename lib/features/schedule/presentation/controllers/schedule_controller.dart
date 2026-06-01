import 'package:flutter_application_2/features/schedule/presentation/controllers/schedule_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/course_entity.dart';
import '../../domain/usecases/get_courses_usecase.dart';

final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController,
        AsyncValue<List<CourseEntity>>>(
  (ref) {
    final useCase = ref.watch(getCoursesUseCaseProvider);

    return ScheduleController(useCase);
  },
);

class ScheduleController
    extends StateNotifier<AsyncValue<List<CourseEntity>>> {
  final GetCoursesUseCase getCoursesUseCase;

  ScheduleController(this.getCoursesUseCase)
      : super(const AsyncValue.loading()) {
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      state = const AsyncValue.loading();

      final courses = await getCoursesUseCase();

      state = AsyncValue.data(courses);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshCourses() async {
    try {
      final courses = await getCoursesUseCase();

      state = AsyncValue.data(courses);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
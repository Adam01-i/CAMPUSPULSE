import 'package:flutter_application_2/features/schedule/presentation/controllers/schedule_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/schedule/domain/entities/course_entity.dart';

final scheduleControllerProvider =
    FutureProvider<List<CourseEntity>>((ref) async {
  final getCourses = ref.watch(getCoursesUseCaseProvider);

  return await getCourses();
});
// lib/features/schedule/presentation/providers/selected_day_courses_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/extensions/course_extensions.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/schedule_controller.dart';

/// Retourne les cours du jour sélectionné, triés chronologiquement.
final selectedDayCoursesProvider = Provider<List<CourseEntity>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final scheduleAsync = ref.watch(scheduleControllerProvider);

  return scheduleAsync.when(
    data: (courses) => courses.forDate(selectedDate),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Retourne les cours de la semaine en cours.
final currentWeekCoursesProvider = Provider<List<CourseEntity>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final scheduleAsync = ref.watch(scheduleControllerProvider);

  return scheduleAsync.when(
    data: (courses) => courses.forWeek(selectedDate),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Retourne le nombre de cours par jour pour la semaine courante.
final weekDayCoursesCountProvider = Provider<Map<int, int>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final scheduleAsync = ref.watch(scheduleControllerProvider);

  return scheduleAsync.when(
    data: (courses) {
      final monday =
          selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      final Map<int, int> counts = {};
      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        counts[i] = courses.forDate(day).length;
      }
      return counts;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// lib/features/schedule/presentation/widgets/schedule_summary_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/extensions/course_extensions.dart';
import '../controllers/schedule_controller.dart';
import '../providers/selected_day_courses_provider.dart';

class ScheduleSummaryCard extends ConsumerWidget {
  const ScheduleSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final todayCourses = ref.watch(selectedDayCoursesProvider);
    final weekCourses = ref.watch(currentWeekCoursesProvider);
    final allCoursesAsync = ref.watch(scheduleControllerProvider);

    final nextCourse = allCoursesAsync.valueOrNull?.nextUpcoming;

    final cardGradient = theme.brightness == Brightness.dark
        ? LinearGradient(
            colors: [
              colorScheme.surfaceVariant,
              colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [colorScheme.primary, colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final headerTextColor = theme.brightness == Brightness.dark
        ? colorScheme.onSurface
        : Colors.white;

    final subtitleTextColor = theme.brightness == Brightness.dark
        ? colorScheme.onSurfaceVariant
        : Colors.white70;

    final cardBackgroundColor = theme.brightness == Brightness.dark
        ? colorScheme.surface
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        gradient: theme.brightness == Brightness.dark ? null : cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: theme.brightness == Brightness.dark
            ? Border.all(color: colorScheme.surfaceVariant.withOpacity(0.15))
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? colorScheme.shadow.withOpacity(0.12)
                : colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Résumé Planning',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: headerTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${todayCourses.length} cours aujourd\'hui · ${weekCourses.length} cette semaine',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (nextCourse != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? colorScheme.surfaceVariant.withOpacity(0.14)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: theme.brightness == Brightness.dark
                          ? colorScheme.onSurface
                          : Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prochain cours',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: subtitleTextColor,
                          ),
                        ),
                        Text(
                          nextCourse.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: headerTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? colorScheme.surfaceVariant.withOpacity(0.14)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Dans ${nextCourse.remainingFormatted}',
                      style: TextStyle(
                        color: theme.brightness == Brightness.dark
                            ? colorScheme.onSurface
                            : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

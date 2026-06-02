// lib/features/schedule/presentation/widgets/daily_timeline.dart

import 'package:flutter/material.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_status.dart';
import '../../domain/extensions/course_extensions.dart';

class DailyTimeline extends StatelessWidget {
  final List<CourseEntity> courses;

  const DailyTimeline({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (courses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline du jour',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...courses.asMap().entries.map((entry) {
          final index = entry.key;
          final course = entry.value;
          final isLast = index == courses.length - 1;
          return _TimelineItem(
            course: course,
            isLast: isLast,
          );
        }),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final CourseEntity course;
  final bool isLast;

  const _TimelineItem({required this.course, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = course.status;
    final statusColor = course.statusColor(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne heure + ligne
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Text(
                  course.startTimeFormatted,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: status == CourseStatus.finished
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (!isLast)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: colorScheme.outlineVariant.withOpacity(0.4),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Dot + indicateur "maintenant"
          Column(
            children: [
              const SizedBox(height: 1),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (status == CourseStatus.running)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: colorScheme.surface, width: 2),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Contenu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label "Maintenant" pour cours en cours
                  if (status == CourseStatus.running) ...[
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Maintenant',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: status == CourseStatus.running
                          ? statusColor.withOpacity(0.08)
                          : colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: status == CourseStatus.running
                            ? statusColor.withOpacity(0.3)
                            : colorScheme.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: status == CourseStatus.finished
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${course.room} · ${course.teacher}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          course.endTimeFormatted,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

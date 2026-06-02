// lib/features/schedule/presentation/widgets/schedule_stats_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/extensions/course_extensions.dart';
import '../providers/selected_day_courses_provider.dart';

class ScheduleStatsRow extends ConsumerWidget {
  const ScheduleStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayCourses = ref.watch(selectedDayCoursesProvider);
    final weekCourses = ref.watch(currentWeekCoursesProvider);

    final remainingToday = todayCourses
        .where((c) => !c.isFinished)
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.today_rounded,
            value: '${todayCourses.length}',
            label: 'Aujourd\'hui',
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_view_week_rounded,
            value: '${weekCourses.length}',
            label: 'Cette semaine',
            color: const Color(0xFF0EA5E9),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.pending_actions_rounded,
            value: '$remainingToday',
            label: 'Restants',
            color: const Color(0xFFF97316),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

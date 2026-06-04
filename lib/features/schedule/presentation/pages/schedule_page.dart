// lib/features/schedule/presentation/pages/schedule_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/schedule_controller.dart';
import '../providers/selected_day_courses_provider.dart';
import '../widgets/course_card.dart';
import '../widgets/daily_timeline.dart';
import '../widgets/empty_schedule_widget.dart';
import '../widgets/schedule_error_widget.dart';
import '../widgets/schedule_skeleton.dart';
import '../widgets/schedule_stats_row.dart';
import '../widgets/schedule_summary_card.dart';
import '../widgets/weekly_calendar.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleControllerProvider);

    return scheduleAsync.when(
      loading: () => const _ScheduleScaffold(child: ScheduleSkeleton()),
      error: (error, _) => _ScheduleScaffold(
        child: ScheduleErrorWidget(
          onRetry: () =>
              ref.read(scheduleControllerProvider.notifier).refreshCourses(),
        ),
      ),
      data: (_) => const _ScheduleScaffold(child: _ScheduleContent()),
    );
  }
}

// ─── Scaffold partagé ────────────────────────
class _ScheduleScaffold extends StatelessWidget {
  final Widget child;
  const _ScheduleScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: child,
    );
  }
}

// ─── Contenu principal ───────────────────────
class _ScheduleContent extends ConsumerWidget {
  const _ScheduleContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedDate = ref.watch(selectedDateProvider);
    final dayCourses = ref.watch(selectedDayCoursesProvider);

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(scheduleControllerProvider.notifier).refreshCourses(),
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            backgroundColor: colorScheme.surface,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planning',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () =>
                    ref.read(selectedDateProvider.notifier).goToToday(),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.today_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ),
                tooltip: 'Aujourd\'hui',
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Summary Card
                const ScheduleSummaryCard(),
                const SizedBox(height: 14),

                // Stats rapides
                const ScheduleStatsRow(),
                const SizedBox(height: 20),

                // Calendrier hebdomadaire
                const WeeklyCalendar(),
                const SizedBox(height: 24),

                // En-tête section cours
                _DaySectionHeader(selectedDate: selectedDate),
                const SizedBox(height: 16),

                // Timeline + cours filtrés
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: dayCourses.isEmpty
                      ? const EmptyScheduleWidget()
                      : _DayContent(
                          key: ValueKey(selectedDate.toIso8601String()),
                          courses: dayCourses,
                        ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header section jour ─────────────────────
class _DaySectionHeader extends StatelessWidget {
  final DateTime selectedDate;
  const _DaySectionHeader({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          'Cours du ',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          _formattedDate(selectedDate),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formattedDate(DateTime date) {
    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${days[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }
}

// ─── Contenu journée (timeline + cards) ──────
class _DayContent extends StatelessWidget {
  final List courses;
  const _DayContent({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline visuelle
        DailyTimeline(courses: courses.cast()),
        const SizedBox(height: 24),

        // Titre cartes détaillées
        Text(
          'Détail des cours',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // Course cards
        ...courses.map((course) => CourseCard(course: course)),
      ],
    );
  }
}
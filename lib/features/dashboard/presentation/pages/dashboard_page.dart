import 'package:flutter/material.dart';
import '../../../schedule/presentation/controllers/schedule_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../schedule/domain/entities/course_entity.dart';
import '../../../schedule/presentation/pages/course_details_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD PAGE — UI/UX refondue, logique métier inchangée
// ─────────────────────────────────────────────────────────────────────────────
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _enter;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _fade = CurvedAnimation(parent: _enter, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: _enter, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final coursesState = ref.watch(scheduleControllerProvider);
    final totalCourses = coursesState.when(
      data: (courses) => courses.length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final today = DateTime.now();

    final todayCourses = coursesState.when(
      data: (courses) => courses.where((course) {
        return course.startTime.year == today.year &&
            course.startTime.month == today.month &&
            course.startTime.day == today.day;
      }).length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final upcomingCoursesCount = coursesState.when(
      data: (courses) => courses
          .where((course) => course.startTime.isAfter(DateTime.now()))
          .length,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  sliver: SliverToBoxAdapter(child: _DashHeader()),
                ),

                // ── Next course card ──────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _NextCourseCard(
                      coursesState: coursesState,
                    ),
                  ),
                ),

                // ── Quick stats ───────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SectionLabel(label: 'Aperçu de la semaine'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  sliver: SliverToBoxAdapter(
                      child: _StatsRow(
                    totalCourses: totalCourses,
                    todayCourses: todayCourses,
                    upcomingCourses: upcomingCoursesCount,
                  )),
                ),

                // ── Today's courses ───────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: _SectionLabel(label: "Cours d'aujourd'hui"),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 100),
                  sliver: coursesState.when(
                    data: (courses) {
                      final today = DateTime.now();

                      final todayCourses = courses.where((course) {
                        return course.startTime.year == today.year &&
                            course.startTime.month == today.month &&
                            course.startTime.day == today.day;
                      }).toList();

                      if (todayCourses.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                "Aucun cours aujourd'hui",
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final course = todayCourses[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CourseRow(
                                course: course,
                                subject: course.title,
                                time:
                                    '${DateFormat('HH:mm').format(course.startTime)} - '
                                    '${DateFormat('HH:mm').format(course.endTime)}',
                                room: course.room,
                                accent: const Color(0xFF6750A4),
                                icon: Icons.school_rounded,
                              ),
                            );
                          },
                          childCount: todayCourses.length,
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    error: (e, _) => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Erreur : $e',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────
class _DashHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, Adam 👋',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat(
                  'EEEE d MMMM yyyy',
                  'fr_FR',
                ).format(DateTime.now()),
              )
            ],
          ),
        ),
        // Avatar with presence dot
        Stack(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF2DC653),
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Next Course Card
// ─────────────────────────────────────────────
class _NextCourseCard extends StatelessWidget {
  final AsyncValue<List<CourseEntity>> coursesState;

  const _NextCourseCard({
    required this.coursesState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6750A4), Color(0xFF42307A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6750A4).withOpacity(0.32),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: coursesState.when(
        data: (List<CourseEntity> courses) {
          if (courses.isEmpty) {
            return const Text(
              'Aucun cours disponible',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          }

          final now = DateTime.now();

          final upcomingCourses =
              courses.where((course) => course.startTime.isAfter(now)).toList();

          upcomingCourses.sort(
            (a, b) => a.startTime.compareTo(b.startTime),
          );

          if (upcomingCourses.isEmpty) {
            return const Text(
              'Aucun cours à venir',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          }

          final nextCourse = upcomingCourses.first;

          final totalMinutesBeforeCourse =
              nextCourse.startTime.difference(now).inMinutes;

          final progress = totalMinutesBeforeCourse <= 0
              ? 1.0
              : (1 - (totalMinutesBeforeCourse / 1440)).clamp(0.0, 1.0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 3.5,
                          backgroundColor: Color(0xFF7EFF9A),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Prochain cours',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                nextCourse.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _Chip(
                    icon: Icons.access_time_rounded,
                    label:
                        '${DateFormat('HH:mm').format(nextCourse.startTime)} - '
                        '${DateFormat('HH:mm').format(nextCourse.endTime)}',
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    icon: Icons.location_on_rounded,
                    label: nextCourse.room,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFF7EFF9A),
                    ),
                  )),
              const SizedBox(height: 6),
              Text(
                'Prof: ${nextCourse.teacher}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Début dans ${nextCourse.startTime.difference(now).inHours} h',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        error: (error, stack) => Text(
          'Erreur : $error',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
    );
  }
}

// ─────────────────────────────────────────────
// Stats row — 3 cards
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final int totalCourses;
  final int todayCourses;
  final int upcomingCourses;

  const _StatsRow({
    required this.totalCourses,
    required this.todayCourses,
    required this.upcomingCourses,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Cours',
            value: totalCourses.toString(),
            icon: Icons.school_rounded,
            color: const Color(0xFF6750A4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'Aujourd’hui',
            value: todayCourses.toString(),
            icon: Icons.event_busy_rounded,
            color: const Color(0xFFE76F51),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'À venir',
            value: upcomingCourses.toString(),
            icon: Icons.assignment_rounded,
            color: const Color(0xFF2A9D8F),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: cs.onSurface,
                ),
          ),
          const SizedBox(height: 1),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Today course row
// ─────────────────────────────────────────────
class _CourseRow extends StatelessWidget {
  final String subject;
  final String time;
  final String room;
  final Color accent;
  final IconData icon;
  final CourseEntity course;

  const _CourseRow({
    required this.subject,
    required this.time,
    required this.room,
    required this.accent,
    required this.icon,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailsPage(
                course: course,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 42,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$time · $room',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

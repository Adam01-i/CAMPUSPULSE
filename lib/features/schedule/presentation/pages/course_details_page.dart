import 'package:flutter/material.dart';
import '../../domain/entities/course_entity.dart';
import 'package:intl/intl.dart';

class CourseDetailsPage extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailsPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du cours'),
      ),
      body: CourseDetailsContent(course: course),
    );
  }
}

class CourseDetailsSheet extends StatelessWidget {
  final CourseEntity course;
  final ScrollController? scrollController;

  const CourseDetailsSheet({
    super.key,
    required this.course,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Détails du cours',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: CourseDetailsContent(course: course),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseDetailsContent extends StatelessWidget {
  final CourseEntity course;

  const CourseDetailsContent({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        _DetailTile(
          icon: Icons.person,
          title: course.teacher,
          subtitle: 'Professeur',
        ),
        _DetailTile(
          icon: Icons.location_on,
          title: course.room,
          subtitle: 'Salle',
        ),
        _DetailTile(
          icon: Icons.access_time,
          title:
              '${DateFormat('HH:mm').format(course.startTime)} - '
              '${DateFormat('HH:mm').format(course.endTime)}',
          subtitle: 'Horaire',
        ),
        _DetailTile(
          icon: Icons.calendar_today,
          title: DateFormat(
            'EEEE d MMMM yyyy',
            'fr_FR',
          ).format(course.startTime),
          subtitle: 'Date',
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.14),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            'Consultation rapide des informations clés du cours sans quitter le tableau de bord.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
          ),
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DetailTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primaryContainer
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

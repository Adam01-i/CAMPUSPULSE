// lib/features/schedule/presentation/widgets/course_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_status.dart';
import '../../domain/extensions/course_extensions.dart';

class CourseCard extends StatelessWidget {
  final CourseEntity course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final status = course.status;
    final statusColor = course.statusColor(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status == CourseStatus.running
              ? statusColor.withOpacity(0.4)
              : colorScheme.outlineVariant.withOpacity(0.3),
          width: status == CourseStatus.running ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: status == CourseStatus.running
                ? statusColor.withOpacity(0.12)
                : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header : heure + badge statut
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne horaire
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.startTimeFormatted,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      course.endTimeFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        course.durationFormatted,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Séparateur vertical coloré
                Container(
                  width: 3,
                  height: 56,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(width: 16),

                // Infos cours
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: status == CourseStatus.finished
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _InfoChip(
                        icon: Icons.location_on_outlined,
                        label: course.room,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      _InfoChip(
                        icon: Icons.person_outline_rounded,
                        label: course.teacher,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Badge statut
                _StatusBadge(status: status, color: statusColor),
              ],
            ),

            // Barre de progression pour EN COURS
            if (status == CourseStatus.running) ...[
              const SizedBox(height: 14),
              _ProgressBar(course: course, color: statusColor),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Status Badge ────────────────────────────
class _StatusBadge extends StatelessWidget {
  final CourseStatus status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == CourseStatus.running)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            _label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    switch (status) {
      case CourseStatus.running:
        return 'EN COURS';
      case CourseStatus.upcoming:
        return 'À VENIR';
      case CourseStatus.finished:
        return 'TERMINÉ';
    }
  }
}

// ─── Info Chip ───────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Progress Bar ────────────────────────────
class _ProgressBar extends StatelessWidget {
  final CourseEntity course;
  final Color color;

  const _ProgressBar({required this.course, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = course.progress;
    final percent = (progress * 100).round();
    final remaining = course.remainingFormatted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$percent% terminé',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$remaining restante',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
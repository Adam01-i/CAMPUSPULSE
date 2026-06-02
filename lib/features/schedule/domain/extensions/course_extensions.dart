// lib/features/schedule/domain/extensions/course_extensions.dart

import 'package:flutter/material.dart';
import '../entities/course_entity.dart';
import '../entities/course_status.dart';

extension CourseExtensions on CourseEntity {
  CourseStatus get status {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return CourseStatus.finished;
    if (now.isAfter(startTime) || now.isAtSameMomentAs(startTime)) {
      return CourseStatus.running;
    }
    return CourseStatus.upcoming;
  }

  bool get isRunning => status == CourseStatus.running;
  bool get isUpcoming => status == CourseStatus.upcoming;
  bool get isFinished => status == CourseStatus.finished;

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  Duration get duration => endTime.difference(startTime);

  double get progress {
    if (isFinished) return 1.0;
    if (isUpcoming) return 0.0;
    final now = DateTime.now();
    final total = endTime.difference(startTime).inSeconds;
    final elapsed = now.difference(startTime).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Duration get remainingTime {
    final now = DateTime.now();
    if (isFinished) return Duration.zero;
    if (isUpcoming) return startTime.difference(now);
    return endTime.difference(now);
  }

  String get durationFormatted {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}h${m.toString().padLeft(2, '0')}';
    if (h > 0) return '${h}h';
    return '${m}min';
  }

  String get remainingFormatted {
    final d = remainingTime;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
  }

  Color statusColor(BuildContext context) {
    switch (status) {
      case CourseStatus.running:
        return const Color(0xFF22C55E); // vert
      case CourseStatus.upcoming:
        return const Color(0xFFF97316); // orange
      case CourseStatus.finished:
        return const Color(0xFF94A3B8); // gris
    }
  }

  String get statusLabel {
    switch (status) {
      case CourseStatus.running:
        return 'EN COURS';
      case CourseStatus.upcoming:
        return 'À VENIR';
      case CourseStatus.finished:
        return 'TERMINÉ';
    }
  }

  String get startTimeFormatted =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

  String get endTimeFormatted =>
      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
}

extension CourseListExtensions on List<CourseEntity> {
  List<CourseEntity> forDate(DateTime date) {
    return where((c) =>
        c.startTime.year == date.year &&
        c.startTime.month == date.month &&
        c.startTime.day == date.day).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<CourseEntity> forWeek(DateTime anyDayInWeek) {
    final monday =
        anyDayInWeek.subtract(Duration(days: anyDayInWeek.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return where((c) =>
        !c.startTime.isBefore(DateTime(monday.year, monday.month, monday.day)) &&
        !c.startTime.isAfter(
            DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59))).toList();
  }

  CourseEntity? get nextUpcoming {
    final now = DateTime.now();
    final upcoming = where((c) => c.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  CourseEntity? get currentlyRunning {
    final now = DateTime.now();
    return firstWhere(
      (c) => !now.isBefore(c.startTime) && !now.isAfter(c.endTime),
      orElse: () => throw StateError('none'),
    );
  }
}

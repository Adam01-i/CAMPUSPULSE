import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import './hive_service.dart';
import './local_notification_service.dart';
import '../../features/notifications/domain/entities/notification_entity.dart';
import '../../features/schedule/domain/entities/course_entity.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final Map<String, Timer> _reminderTimers = {};
  static Timer? _dailyPlanningTimer;

  Future<void> initialize() async {
    await LocalNotificationService.init();
  }

  static Future<bool> _notificationsEnabled() async {
    try {
      return HiveService.getSettingsBox()
          .get(HiveService.notificationsEnabledKey, defaultValue: true) as bool;
    } on HiveError {
      await HiveService.init();
      return HiveService.getSettingsBox()
          .get(HiveService.notificationsEnabledKey, defaultValue: true) as bool;
    } catch (_) {
      return true;
    }
  }

  static Future<void> createCourseNotification(CourseEntity course) async {
    debugPrint('[NOTIFICATION] Cours detecte: ${course.id}');

    await _createNotification(
      id: 'new_course_${course.id}',
      title: 'Nouveau cours ajouté',
      body: '${course.title} - Salle ${course.room}',
      type: NotificationType.newCourse,
      courseId: course.id,
      localChannelId: 'course_added_channel',
      localChannelName: 'Nouveaux cours',
      dispatchFcm: true,
    );
  }

  static Future<void> createRoomChangedNotification({
    required CourseEntity course,
    required String oldRoom,
    required String newRoom,
  }) async {
    debugPrint('[NOTIFICATION] Salle modifiee: $oldRoom -> $newRoom');

    await _createNotification(
      id: 'room_changed_${course.id}_${_docSafe(newRoom)}',
      title: 'Changement de salle',
      body: '${course.title} est déplacé en salle $newRoom',
      type: NotificationType.roomChanged,
      courseId: course.id,
      localChannelId: 'room_changed_channel',
      localChannelName: 'Changements de salle',
      dispatchFcm: true,
      extra: {'oldRoom': oldRoom, 'newRoom': newRoom},
    );
  }

  static Future<void> createCourseCancelledNotification(
    CourseEntity course,
  ) async {
    await _createNotification(
      id: 'course_cancelled_${course.id}',
      title: 'Cours annulé',
      body: 'Le cours ${course.title} a été annulé',
      type: NotificationType.courseCancelled,
      courseId: course.id,
      localChannelId: 'course_cancelled_channel',
      localChannelName: 'Cours annulés',
      dispatchFcm: true,
    );
  }

  static Future<void> createDailyPlanningNotification() async {
    final today = DateTime.now();
    final courses = await _getCoursesForDay(today);
    final id = _dailyPlanningNotificationId(today);

    await _createNotification(
      id: id,
      title: 'Planning du jour',
      body: "Vous avez ${courses.length} cours aujourd'hui",
      type: NotificationType.reminder,
      localChannelId: 'daily_planning_channel',
      localChannelName: 'Planning quotidien',
      dispatchFcm: false,
      extra: {'courseCount': courses.length},
    );
  }

  static Future<void> scheduleReminder(CourseEntity course) async {
    final reminderAt = course.startTime.subtract(const Duration(minutes: 15));
    final now = DateTime.now();
    final timerId = 'course_reminder_${course.id}';

    _reminderTimers[timerId]?.cancel();

    if (!course.startTime.isAfter(now)) {
      return;
    }

    if (!reminderAt.isAfter(now)) {
      debugPrint('[NOTIFICATION] Rappel imminent: ${course.id}');
      await createCourseReminderNotification(course);
      return;
    }

    final delay = reminderAt.difference(now);
    _reminderTimers[timerId] = Timer(delay, () {
      createCourseReminderNotification(course);
      _reminderTimers.remove(timerId);
    });

    debugPrint('[NOTIFICATION] Rappel programme: ${course.id} a $reminderAt');
  }

  static Future<void> createCourseReminderNotification(CourseEntity course) {
    return _createNotification(
      id: 'course_reminder_${course.id}_${course.startTime.millisecondsSinceEpoch}',
      title: 'Rappel de cours',
      body: '${course.title} commence dans 15 minutes',
      type: NotificationType.reminder,
      courseId: course.id,
      localChannelId: 'course_reminder_channel',
      localChannelName: 'Rappels de cours',
      dispatchFcm: false,
    );
  }

  static Future<void> initAppReminders() async {
    final snapshot = await _firestore.collection('courses').get();

    for (final doc in snapshot.docs) {
      try {
        final course = CourseEntity.fromMap(doc.data(), doc.id);
        await scheduleReminder(course);
      } catch (error) {
        debugPrint('[NOTIFICATION] Cours ignore: ${doc.id} ($error)');
      }
    }
  }

  static Future<void> startDailyPlanningScheduler() async {
    _dailyPlanningTimer?.cancel();

    final now = DateTime.now();
    final todayAtSeven = DateTime(now.year, now.month, now.day, 7);
    final todayId = _dailyPlanningNotificationId(now);

    if (!now.isBefore(todayAtSeven)) {
      final alreadyCreated =
          await _firestore.collection('notifications').doc(todayId).get();
      if (!alreadyCreated.exists) {
        await createDailyPlanningNotification();
      }
    }

    _scheduleNextDailyPlanningTick();
  }

  static void stopSchedulers() {
    _dailyPlanningTimer?.cancel();
    _dailyPlanningTimer = null;
    for (final timer in _reminderTimers.values) {
      timer.cancel();
    }
    _reminderTimers.clear();
  }

  static Future<bool> _createNotification({
    required String id,
    required String title,
    required String body,
    required NotificationType type,
    required String localChannelId,
    required String localChannelName,
    String? courseId,
    bool dispatchFcm = false,
    Map<String, dynamic> extra = const {},
  }) async {
    final doc = _firestore.collection('notifications').doc(id);
    final existing = await doc.get();

    if (existing.exists) {
      debugPrint('[NOTIFICATION] Notification deja presente: $id');
      return false;
    }

    final payload = {
      'id': id,
      'title': title,
      'body': body,
      'createdAt': Timestamp.now(),
      'type': type.name,
      'isRead': false,
      if (courseId != null) 'courseId': courseId,
      ...extra,
    };

    await doc.set(payload);
    debugPrint('[NOTIFICATION] Notification creee: $id');

    if (await _notificationsEnabled()) {
      await LocalNotificationService.showNotification(
        id: _stableNotificationId(id),
        title: title,
        body: body,
        channelId: localChannelId,
        channelName: localChannelName,
      );
    }

    if (dispatchFcm) {
      await _queueFcmDispatch(
        notificationId: id,
        title: title,
        body: body,
        type: type,
        courseId: courseId,
      );
    }

    return true;
  }

  static Future<void> _queueFcmDispatch({
    required String notificationId,
    required String title,
    required String body,
    required NotificationType type,
    String? courseId,
  }) async {
    await _firestore
        .collection('notificationDispatchQueue')
        .doc(notificationId)
        .set({
      'notificationId': notificationId,
      'title': title,
      'body': body,
      'type': type.name,
      'topic': 'campus_notifications',
      'courseId': courseId,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });

    debugPrint('[NOTIFICATION] Demande FCM creee: $notificationId');
  }

  static void _scheduleNextDailyPlanningTick() {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, 7);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    _dailyPlanningTimer = Timer(next.difference(now), () async {
      await createDailyPlanningNotification();
      _scheduleNextDailyPlanningTick();
    });

    debugPrint('[NOTIFICATION] Rappel quotidien programme: $next');
  }

  static Future<List<CourseEntity>> _getCoursesForDay(DateTime day) async {
    final snapshot = await _firestore.collection('courses').get();
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final courses = <CourseEntity>[];

    for (final doc in snapshot.docs) {
      try {
        final course = CourseEntity.fromMap(doc.data(), doc.id);
        final startsToday =
            !course.startTime.isBefore(start) && course.startTime.isBefore(end);
        if (startsToday) {
          courses.add(course);
        }
      } catch (_) {
        continue;
      }
    }

    return courses;
  }

  static String _dailyPlanningNotificationId(DateTime day) {
    final date =
        '${day.year}'
        '${day.month.toString().padLeft(2, '0')}'
        '${day.day.toString().padLeft(2, '0')}';
    return 'daily_planning_$date';
  }

  static String _docSafe(String value) {
    return value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
  }

  static int _stableNotificationId(String value) => value.hashCode & 0x7fffffff;
}

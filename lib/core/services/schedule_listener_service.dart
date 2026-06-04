import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/schedule/domain/entities/course_entity.dart';
import 'notification_service.dart';

class ScheduleListenerService {
  static StreamSubscription? _sub;
  static bool _initialSnapshotHandled = false;

  static void startListening() {
    _initialSnapshotHandled = false;

    _sub = FirebaseFirestore.instance
        .collection('courses')
        .snapshots()
        .listen((snapshot) {
      if (!_initialSnapshotHandled) {
        _initialSnapshotHandled = true;
        return;
      }

      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          try {
            final course =
                CourseEntity.fromMap(change.doc.data()!, change.doc.id);
            NotificationService.createCourseNotification(course);
            NotificationService.scheduleReminder(course);
          } catch (_) {
            // Ignore malformed course documents instead of generating a wrong entry.
          }
        }
      }
    });
  }

  static void stop() {
    _sub?.cancel();
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../features/schedule/domain/entities/course_entity.dart';
import 'notification_service.dart';

class ScheduleListenerService {
  static StreamSubscription? _sub;
  static final Map<String, Map<String, dynamic>> _knownCourses = {};
  static bool _initialSnapshotHandled = false;

  static void startListening() {
    _sub?.cancel();
    _knownCourses.clear();
    _initialSnapshotHandled = false;

    _sub = FirebaseFirestore.instance.collection('courses').snapshots().listen(
      (snapshot) {
        if (!_initialSnapshotHandled) {
          for (final doc in snapshot.docs) {
            _knownCourses[doc.id] = Map<String, dynamic>.from(doc.data());
          }
          _initialSnapshotHandled = true;
          debugPrint('[NOTIFICATION] Cours existants indexes: ${snapshot.size}');
          return;
        }

        for (final change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null) {
            continue;
          }

          switch (change.type) {
            case DocumentChangeType.added:
              _handleAdded(change.doc.id, data);
              break;
            case DocumentChangeType.modified:
              _handleModified(change.doc.id, data);
              break;
            case DocumentChangeType.removed:
              _knownCourses.remove(change.doc.id);
              break;
          }
        }
      },
      onError: (error, stackTrace) {
        debugPrint('[NOTIFICATION] Ecoute courses en erreur: $error');
      },
    );
  }

  static void stop() {
    _sub?.cancel();
    _sub = null;
    _knownCourses.clear();
  }

  static Future<void> _handleAdded(
    String id,
    Map<String, dynamic> data,
  ) async {
    _knownCourses[id] = Map<String, dynamic>.from(data);

    try {
      final course = CourseEntity.fromMap(data, id);
      await NotificationService.createCourseNotification(course);
      await NotificationService.scheduleReminder(course);

      if (_isCancelled(data)) {
        await NotificationService.createCourseCancelledNotification(course);
      }
    } catch (error) {
      debugPrint('[NOTIFICATION] Cours ajoute invalide: $id ($error)');
    }
  }

  static Future<void> _handleModified(
    String id,
    Map<String, dynamic> data,
  ) async {
    final previous = _knownCourses[id];
    _knownCourses[id] = Map<String, dynamic>.from(data);

    if (previous == null) {
      return;
    }

    try {
      final course = CourseEntity.fromMap(data, id);
      await NotificationService.scheduleReminder(course);

      final oldRoom = (previous['room'] ?? '').toString();
      final newRoom = (data['room'] ?? '').toString();

      if (oldRoom.isNotEmpty && newRoom.isNotEmpty && oldRoom != newRoom) {
        await NotificationService.createRoomChangedNotification(
          course: course,
          oldRoom: oldRoom,
          newRoom: newRoom,
        );
      }

      final wasCancelled = _isCancelled(previous);
      final isCancelled = _isCancelled(data);

      if (!wasCancelled && isCancelled) {
        debugPrint('[NOTIFICATION] Annulation detectee: $id');
        await NotificationService.createCourseCancelledNotification(course);
      }
    } catch (error) {
      debugPrint('[NOTIFICATION] Cours modifie invalide: $id ($error)');
    }
  }

  static bool _isCancelled(Map<String, dynamic> data) {
    final status = data['status']?.toString().toLowerCase().trim();
    final isCancelled = data['isCancelled'] == true;

    return status == 'cancelled' ||
        status == 'canceled' ||
        status == 'annule' ||
        status == 'annulé' ||
        isCancelled;
  }
}

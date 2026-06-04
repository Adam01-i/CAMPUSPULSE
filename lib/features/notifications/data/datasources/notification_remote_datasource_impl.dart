import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'notification_local_datasource.dart';

class NotificationRemoteDataSourceImpl implements NotificationLocalDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final snapshot = await firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;

      final rawCreatedAt = data['createdAt'];
      final createdAt = rawCreatedAt is Timestamp
          ? rawCreatedAt.toDate()
          : rawCreatedAt is String
              ? DateTime.parse(rawCreatedAt)
              : rawCreatedAt is DateTime
                  ? rawCreatedAt
                  : DateTime.now();

      return NotificationModel.fromMap({
        ...data,
        'createdAt': createdAt.toIso8601String(),
      });
    }).toList();
  }

  @override
  Future<void> saveNotification(NotificationModel model) async {
    await firestore
        .collection('notifications')
        .doc(model.id)
        .set(model.toMap());
  }

  @override
  Future<void> updateNotification(NotificationModel model) async {
    await firestore
        .collection('notifications')
        .doc(model.id)
        .update(model.toMap());
  }

  @override
  Future<void> deleteNotification(String id) async {
    await firestore.collection('notifications').doc(id).delete();
  }

  @override
  Future<void> markAllAsRead() async {
    final batch = firestore.batch();

    final snapshot = await firestore.collection('notifications').get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }
}
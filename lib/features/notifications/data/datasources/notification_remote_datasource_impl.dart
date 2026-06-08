import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';
import 'notification_remote_datasource.dart';

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final snapshot = await firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .get();

    return _decodeNotifications(snapshot);
  }

  Stream<List<NotificationModel>> watchNotifications() {
    return firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_decodeNotifications);
  }

  List<NotificationModel> _decodeNotifications(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;

          return NotificationModel.fromMap(data);
        })
        .where((notification) => notification.type != NotificationType.admin)
        .toList();
  }

  @override
  Future<void> saveNotification(NotificationModel model) async {
    final collection = firestore.collection('notifications');
    final doc = model.id.isEmpty ? collection.doc() : collection.doc(model.id);

    await doc.set({
      ...model.toMap(),
      'id': doc.id,
    });
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

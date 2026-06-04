import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import 'schedule_remote_datasource.dart';

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final FirebaseFirestore firestore;

  ScheduleRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<CourseModel>> getCourses() async {
    final snapshot = await firestore.collection('courses').get();

    return snapshot.docs.map((doc) {
      return CourseModel.fromJson(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<void> createCourse(CourseModel course) async {
    await firestore.collection('courses').add(course.toJson());
  }
}

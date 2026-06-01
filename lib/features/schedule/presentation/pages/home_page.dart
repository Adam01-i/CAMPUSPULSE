import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/course_entity.dart';
import '../controllers/schedule_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync =
        ref.watch(scheduleControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusPulse'),
      ),
      body: coursesAsync.when(
        data: (courses) {
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (
              context,
              index,
            ) {
              final CourseEntity course =
                  courses[index];

              return Card(
                margin:
                    const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(
                    Icons.school,
                  ),
                  title: Text(
                    course.title,
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Salle : ${course.room}',
                      ),
                      Text(
                        'Professeur : ${course.teacher}',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Text(
              error.toString(),
            ),
          );
        },
      ),
    );
  }
}
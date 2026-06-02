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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.title,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
            ),

            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.person),
              title: Text(course.teacher),
              subtitle: const Text('Professeur'),
            ),

            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(course.room),
              subtitle: const Text('Salle'),
            ),

            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                '${DateFormat('HH:mm').format(course.startTime)} - '
                '${DateFormat('HH:mm').format(course.endTime)}',
              ),
              subtitle: const Text('Horaire'),
            ),

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                DateFormat(
                  'EEEE d MMMM yyyy',
                  'fr_FR',
                ).format(course.startTime),
              ),
              subtitle: const Text('Date'),
            ),
          ],
        ),
      ),
    );
  }
}
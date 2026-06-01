import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/schedule_controller.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_schedule_widget.dart';
import '../widgets/schedule_error_widget.dart';
import '../widgets/schedule_loading_widget.dart';
import '../widgets/weekly_calendar.dart';
import '../../../../core/services/notification_service.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleState = ref.watch(scheduleControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusPulse'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await NotificationService.instance.showNotification(
            id: 1,
            title: 'CampusPulse',
            body: 'Test notification',
          );
        },
        child: const Icon(Icons.notifications),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const WeeklyCalendar(),
            const SizedBox(height: 20),
            Expanded(
              child: scheduleState.when(
                loading: () => const ScheduleLoadingWidget(),
                error: (error, stackTrace) {
                  return ScheduleErrorWidget(
                    onRetry: () {
                      ref
                          .read(scheduleControllerProvider.notifier)
                          .loadCourses();
                    },
                  );
                },
                data: (courses) {
                  if (courses.isEmpty) {
                    return const EmptyScheduleWidget();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(scheduleControllerProvider.notifier)
                          .refreshCourses();
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];

                        return CourseCard(course: course);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

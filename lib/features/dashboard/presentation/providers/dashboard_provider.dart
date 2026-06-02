import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../schedule/presentation/controllers/schedule_controller.dart';

final dashboardCoursesProvider =
    Provider((ref) {
  return ref.watch(scheduleControllerProvider);
});
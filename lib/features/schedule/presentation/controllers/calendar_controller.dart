// lib/features/schedule/presentation/controllers/calendar_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDateNotifier extends StateNotifier<DateTime> {
  SelectedDateNotifier() : super(DateTime.now());

  void selectDate(DateTime date) {
    state = date;
  }

  void previousWeek() {
    state = state.subtract(const Duration(days: 7));
  }

  void nextWeek() {
    state = state.add(const Duration(days: 7));
  }

  void goToToday() {
    state = DateTime.now();
  }
}

final selectedDateProvider =
    StateNotifierProvider<SelectedDateNotifier, DateTime>(
  (ref) => SelectedDateNotifier(),
);
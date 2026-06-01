import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedDateProvider =
    StateNotifierProvider<CalendarController, DateTime>(
  (ref) {
    return CalendarController();
  },
);

class CalendarController extends StateNotifier<DateTime> {
  CalendarController() : super(DateTime.now());

  void selectDate(DateTime date) {
    state = date;
  }

  void nextWeek() {
    state = state.add(const Duration(days: 7));
  }

  void previousWeek() {
    state = state.subtract(const Duration(days: 7));
  }
}

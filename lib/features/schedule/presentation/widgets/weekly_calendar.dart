import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/calendar_controller.dart';

class WeeklyCalendar extends ConsumerWidget {
  const WeeklyCalendar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);

    final startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    final days = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  ref
                      .read(selectedDateProvider.notifier)
                      .previousWeek();
                },
                icon: const Icon(Icons.chevron_left),
              ),

              Text(
                '${selectedDate.month}/${selectedDate.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              IconButton(
                onPressed: () {
                  ref
                      .read(selectedDateProvider.notifier)
                      .nextWeek();
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isSelected =
                  day.day == selectedDate.day &&
                  day.month == selectedDate.month &&
                  day.year == selectedDate.year;

              return GestureDetector(
                onTap: () {
                  ref
                      .read(selectedDateProvider.notifier)
                      .selectDate(day);
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),

                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.blue
                            : Colors.transparent,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Column(
                    children: [
                      Text(
                        _dayName(day.weekday),

                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '${day.day}',

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mer';
      case 4:
        return 'Jeu';
      case 5:
        return 'Ven';
      case 6:
        return 'Sam';
      default:
        return 'Dim';
    }
  }
}

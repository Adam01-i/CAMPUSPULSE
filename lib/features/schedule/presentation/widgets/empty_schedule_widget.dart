import 'package:flutter/material.dart';

class EmptyScheduleWidget extends StatelessWidget {
  const EmptyScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Aucun cours disponible',
      ),
    );
  }
}
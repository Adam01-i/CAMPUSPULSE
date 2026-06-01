import 'package:flutter/material.dart';

class ScheduleLoadingWidget extends StatelessWidget {
  const ScheduleLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
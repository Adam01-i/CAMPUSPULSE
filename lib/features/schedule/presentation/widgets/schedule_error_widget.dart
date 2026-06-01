import 'package:flutter/material.dart';

class ScheduleErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const ScheduleErrorWidget({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),

          const SizedBox(height: 16),

          const Text(
            'Une erreur est survenue',
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
// lib/features/notifications/presentation/widgets/notification_loading_state.dart

import 'package:flutter/material.dart';

class NotificationLoadingState extends StatefulWidget {
  const NotificationLoadingState({super.key});

  @override
  State<NotificationLoadingState> createState() =>
      _NotificationLoadingStateState();
}

class _NotificationLoadingStateState extends State<NotificationLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  late final Animation<double> _anim =
      Tween<double>(begin: 0.35, end: 0.85).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SkeletonCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7);
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 12, width: 140, color: color),
                const SizedBox(height: 8),
                Container(height: 10, width: double.infinity, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// lib/features/schedule/presentation/widgets/schedule_skeleton.dart

import 'package:flutter/material.dart';

class ScheduleSkeleton extends StatefulWidget {
  const ScheduleSkeleton({super.key});

  @override
  State<ScheduleSkeleton> createState() => _ScheduleSkeletonState();
}

class _ScheduleSkeletonState extends State<ScheduleSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final Animation<double> _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
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
      builder: (context, _) {
        return Opacity(
          opacity: _anim.value,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(height: 130, borderRadius: 24),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _SkeletonBox(height: 80, borderRadius: 16)),
                    const SizedBox(width: 10),
                    Expanded(child: _SkeletonBox(height: 80, borderRadius: 16)),
                    const SizedBox(width: 10),
                    Expanded(child: _SkeletonBox(height: 80, borderRadius: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                _SkeletonBox(height: 110, borderRadius: 24),
                const SizedBox(height: 20),
                _SkeletonBox(height: 18, width: 160, borderRadius: 8),
                const SizedBox(height: 12),
                _SkeletonBox(height: 100, borderRadius: 20),
                const SizedBox(height: 12),
                _SkeletonBox(height: 100, borderRadius: 20),
                const SizedBox(height: 12),
                _SkeletonBox(height: 100, borderRadius: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const _SkeletonBox({
    required this.height,
    this.width,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

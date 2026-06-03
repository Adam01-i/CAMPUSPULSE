// lib/features/notifications/presentation/widgets/notification_card.dart

import 'package:flutter/material.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationCard extends StatefulWidget {
  final NotificationEntity item;
  final VoidCallback onTap;
  final Duration animationDelay;

  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.animationDelay,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.animationDelay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final config = notifConfig(widget.item.type);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: widget.item.isRead
                ? colorScheme.surfaceContainerLow
                : colorScheme.secondaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: config.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child:
                          Icon(config.icon, color: config.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: widget.item.isRead
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                      ),
                                ),
                              ),
                              Text(
                                _timeLabel(widget.item.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.item.body,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: widget.item.isRead
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurface
                                          .withOpacity(0.8),
                                  height: 1.5,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!widget.item.isRead) ...[
                      const SizedBox(width: 10),
                      Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} j';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Config icône/couleur par type ───────────
class NotifConfigData {
  final IconData icon;
  final Color color;
  const NotifConfigData({required this.icon, required this.color});
}

NotifConfigData notifConfig(NotificationType type) {
  switch (type) {
    case NotificationType.newCourse:
      return const NotifConfigData(
          icon: Icons.add_circle_outline_rounded, color: Color(0xFF6750A4));
    case NotificationType.roomChanged:
      return const NotifConfigData(
          icon: Icons.meeting_room_rounded, color: Color(0xFF0077B6));
    case NotificationType.courseCancelled:
      return const NotifConfigData(
          icon: Icons.cancel_outlined, color: Color(0xFFE76F51));
    case NotificationType.reminder:
      return const NotifConfigData(
          icon: Icons.alarm_rounded, color: Color(0xFFF4A261));
    case NotificationType.admin:
      return const NotifConfigData(
          icon: Icons.admin_panel_settings_rounded, color: Color(0xFF2A9D8F));
  }
}

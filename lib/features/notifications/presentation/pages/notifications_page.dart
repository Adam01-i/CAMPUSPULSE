import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
enum NotificationType { course, grade, event, admin, reminder }

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        body: body,
        timeLabel: timeLabel,
        type: type,
        isRead: isRead ?? this.isRead,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  final List<NotificationItem> _notifications = [
    const NotificationItem(
      id: '1',
      title: 'Cours annulé',
      body: 'Le cours de Mathématiques du jeudi est annulé. Salle de remplacement à confirmer.',
      timeLabel: 'Il y a 5 min',
      type: NotificationType.course,
      isRead: false,
    ),
    const NotificationItem(
      id: '2',
      title: 'Note publiée',
      body: 'Votre note pour "Algorithmique Avancée" est disponible : 16/20.',
      timeLabel: 'Il y a 1h',
      type: NotificationType.grade,
      isRead: false,
    ),
    const NotificationItem(
      id: '3',
      title: 'Rappel – Devoir à rendre',
      body: 'Le rendu du TP Base de Données est prévu demain à 23h59.',
      timeLabel: 'Il y a 3h',
      type: NotificationType.reminder,
      isRead: false,
    ),
    const NotificationItem(
      id: '4',
      title: 'Événement campus',
      body: 'Forum des métiers du numérique — Vendredi 7 juin au hall B.',
      timeLabel: 'Hier',
      type: NotificationType.event,
      isRead: true,
    ),
    const NotificationItem(
      id: '5',
      title: 'Message administratif',
      body: 'Les inscriptions pédagogiques pour le S2 sont ouvertes jusqu\'au 15 juin.',
      timeLabel: 'Hier',
      type: NotificationType.admin,
      isRead: true,
    ),
    const NotificationItem(
      id: '6',
      title: 'Changement de salle',
      body: 'Le cours de Développement Mobile est déplacé en salle C301.',
      timeLabel: 'Il y a 2 j',
      type: NotificationType.course,
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  void _markRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final unread = _notifications.where((n) => !n.isRead).toList();
    final read = _notifications.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── App Bar ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            if (_unreadCount > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                '$_unreadCount non lue${_unreadCount > 1 ? 's' : ''}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_unreadCount > 0)
                        TextButton(
                          onPressed: _markAllRead,
                          child: const Text('Tout lire'),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Unread ────────────────────────────────────────────────
              if (unread.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: _GroupLabel(label: 'Non lues', count: unread.length),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _NotificationCard(
                        item: unread[i],
                        onTap: () => _markRead(unread[i].id),
                        animationDelay:
                            Duration(milliseconds: 80 + i * 60),
                      ),
                      childCount: unread.length,
                    ),
                  ),
                ),
              ],

              // ── Read ──────────────────────────────────────────────────
              if (read.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: _GroupLabel(label: 'Lues', count: read.length),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _NotificationCard(
                        item: read[i],
                        onTap: () {},
                        animationDelay: Duration(
                            milliseconds: 80 + (unread.length + i) * 60),
                      ),
                      childCount: read.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Group Label
// ─────────────────────────────────────────────
class _GroupLabel extends StatelessWidget {
  final String label;
  final int count;
  const _GroupLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Notification Card
// ─────────────────────────────────────────────
class _NotificationCard extends StatefulWidget {
  final NotificationItem item;
  final VoidCallback onTap;
  final Duration animationDelay;

  const _NotificationCard({
    required this.item,
    required this.onTap,
    required this.animationDelay,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
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
    final config = _notifConfig(widget.item.type);

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
                    // Icon container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: config.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(config.icon, color: config.color, size: 22),
                    ),
                    const SizedBox(width: 14),
                    // Content
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
                                widget.item.timeLabel,
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
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
}

// ─────────────────────────────────────────────
// Config helper
// ─────────────────────────────────────────────
class _NotifConfig {
  final IconData icon;
  final Color color;
  const _NotifConfig({required this.icon, required this.color});
}

_NotifConfig _notifConfig(NotificationType type) {
  switch (type) {
    case NotificationType.course:
      return const _NotifConfig(
          icon: Icons.school_rounded, color: Color(0xFF6750A4));
    case NotificationType.grade:
      return const _NotifConfig(
          icon: Icons.grade_rounded, color: Color(0xFF2A9D8F));
    case NotificationType.event:
      return const _NotifConfig(
          icon: Icons.event_rounded, color: Color(0xFF0077B6));
    case NotificationType.admin:
      return const _NotifConfig(
          icon: Icons.admin_panel_settings_rounded, color: Color(0xFFE76F51));
    case NotificationType.reminder:
      return const _NotifConfig(
          icon: Icons.alarm_rounded, color: Color(0xFFF4A261));
  }
}
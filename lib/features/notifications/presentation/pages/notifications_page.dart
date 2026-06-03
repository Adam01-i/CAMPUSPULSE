// lib/features/notifications/presentation/pages/notifications_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_entity.dart';
import '../controllers/notifications_controller.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_error_state.dart';
import '../widgets/notification_loading_state.dart';

// ─── Filtre actif ────────────────────────────
enum _Filter { all, unread, course, reminder, admin }

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  _Filter _activeFilter = _Filter.all;

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

  List<NotificationEntity> _applyFilter(List<NotificationEntity> all) {
    switch (_activeFilter) {
      case _Filter.all:
        return all;
      case _Filter.unread:
        return all.where((n) => !n.isRead).toList();
      case _Filter.course:
        return all
            .where((n) =>
                n.type == NotificationType.newCourse ||
                n.type == NotificationType.roomChanged ||
                n.type == NotificationType.courseCancelled)
            .toList();
      case _Filter.reminder:
        return all.where((n) => n.type == NotificationType.reminder).toList();
      case _Filter.admin:
        return all.where((n) => n.type == NotificationType.admin).toList();
    }
  }

  // Regroupement temporel
  Map<String, List<NotificationEntity>> _group(
      List<NotificationEntity> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final Map<String, List<NotificationEntity>> groups = {
      'Aujourd\'hui': [],
      'Hier': [],
      'Cette semaine': [],
      'Anciennes': [],
    };

    for (final n in notifications) {
      final d = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (!d.isBefore(today)) {
        groups['Aujourd\'hui']!.add(n);
      } else if (d == yesterday) {
        groups['Hier']!.add(n);
      } else if (d.isAfter(weekAgo)) {
        groups['Cette semaine']!.add(n);
      } else {
        groups['Anciennes']!.add(n);
      }
    }

    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(notificationsControllerProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: state.when(
            loading: () => const NotificationLoadingState(),
            error: (_, __) => NotificationErrorState(
              onRetry: () => ref
                  .read(notificationsControllerProvider.notifier)
                  .loadNotifications(),
            ),
            data: (notifications) {
              final filtered = _applyFilter(notifications);
              final groups = _group(filtered);

              return RefreshIndicator(
                onRefresh: () => ref
                    .read(notificationsControllerProvider.notifier)
                    .refreshNotifications(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── App Bar ──────────────────────────────────────────
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
                                  if (unreadCount > 0) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '$unreadCount non lue${unreadCount > 1 ? 's' : ''}',
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
                            if (unreadCount > 0)
                              TextButton(
                                onPressed: () => ref
                                    .read(notificationsControllerProvider
                                        .notifier)
                                    .markAllAsReadAction(),
                                child: const Text('Tout lire'),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ── Filtres ──────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: _FilterBar(
                        active: _activeFilter,
                        onChanged: (f) => setState(() => _activeFilter = f),
                      ),
                    ),

                    // ── Contenu ──────────────────────────────────────────
                    if (filtered.isEmpty)
                      const SliverFillRemaining(
                        child: NotificationEmptyState(),
                      )
                    else ...[
                      for (final entry in groups.entries) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 28, 24, 12),
                            child: _GroupLabel(
                              label: entry.key,
                              count: entry.value.length,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) {
                                final notif = entry.value[i];
                                final globalIndex =
                                    notifications.indexOf(notif);
                                return NotificationCard(
                                  item: notif,
                                  onTap: () => ref
                                      .read(notificationsControllerProvider
                                          .notifier)
                                      .markAsRead(notif.id),
                                  animationDelay: Duration(
                                      milliseconds:
                                          80 + globalIndex * 60),
                                );
                              },
                              childCount: entry.value.length,
                            ),
                          ),
                        ),
                      ],
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Barre de filtres ─────────────────────────
class _FilterBar extends StatelessWidget {
  final _Filter active;
  final ValueChanged<_Filter> onChanged;

  const _FilterBar({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const filters = [
      (_Filter.all, 'Tous'),
      (_Filter.unread, 'Non lues'),
      (_Filter.course, 'Cours'),
      (_Filter.reminder, 'Rappels'),
      (_Filter.admin, 'Administration'),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (filter, label) = filters[i];
          final isActive = active == filter;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: () => onChanged(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Group Label ─────────────────────────────
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
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
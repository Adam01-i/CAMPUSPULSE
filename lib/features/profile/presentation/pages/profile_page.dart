// lib/features/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/auth/presentation/controllers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_entity.dart';
import '../controllers/profile_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoRefreshEnabled = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: profileState.when(
            loading: () => const _ProfileSkeleton(),
            error: (_, __) => _ProfileErrorState(
              onRetry: () =>
                  ref.read(profileControllerProvider.notifier).loadProfile(),
            ),
            data: (profile) => _ProfileContent(
              profile: profile,
              notificationsEnabled: _notificationsEnabled,
              darkModeEnabled: _darkModeEnabled,
              autoRefreshEnabled: _autoRefreshEnabled,
              onNotificationsChanged: (v) =>
                  setState(() => _notificationsEnabled = v),
              onDarkModeChanged: (v) => setState(() => _darkModeEnabled = v),
              onAutoRefreshChanged: (v) =>
                  setState(() => _autoRefreshEnabled = v),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Contenu principal
// ─────────────────────────────────────────────
class _ProfileContent extends StatelessWidget {
  final ProfileEntity profile;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final bool autoRefreshEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<bool> onAutoRefreshChanged;

  const _ProfileContent({
    required this.profile,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.autoRefreshEnabled,
    required this.onNotificationsChanged,
    required this.onDarkModeChanged,
    required this.onAutoRefreshChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Header ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Text(
              'Profil',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
        ),

        // ── Identity Card ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: _ProfileIdentityCard(profile: profile),
          ),
        ),

        // ── Infos universitaires ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: _UniversityInfoCard(profile: profile),
          ),
        ),

        // ── Préférences ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Text(
              'Préférences',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _ToggleSettingsItem(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFF6750A4),
                title: 'Notifications',
                subtitle: 'Alertes liées à votre planning',
                value: notificationsEnabled,
                onChanged: onNotificationsChanged,
              ),
              const SizedBox(height: 8),
              _ToggleSettingsItem(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF0077B6),
                title: 'Mode sombre',
                subtitle: 'Thème de l\'interface',
                value: darkModeEnabled,
                onChanged: onDarkModeChanged,
              ),
              const SizedBox(height: 8),
              _ToggleSettingsItem(
                icon: Icons.sync_rounded,
                iconColor: const Color(0xFF2A9D8F),
                title: 'Actualisation automatique',
                subtitle: 'Mise à jour en arrière-plan',
                value: autoRefreshEnabled,
                onChanged: onAutoRefreshChanged,
              ),
            ]),
          ),
        ),

        // ── Compte ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
            child: Text(
              'Compte',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _ActionSettingsItem(
                icon: Icons.person_outline_rounded,
                iconColor: const Color(0xFF2A9D8F),
                title: 'Modifier le profil',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _ActionSettingsItem(
                icon: Icons.lock_outline_rounded,
                iconColor: const Color(0xFFF4A261),
                title: 'Changer le mot de passe',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _ActionSettingsItem(
                icon: Icons.help_outline_rounded,
                iconColor: const Color(0xFF4CC9F0),
                title: 'Aide & Support',
                onTap: () {},
              ),
              const SizedBox(height: 8),
              _ActionSettingsItem(
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF6750A4),
                title: 'À propos de CampusPulse',
                onTap: () => _showAboutDialog(context),
              ),
            ]),
          ),
        ),

        // ── Déconnexion ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: _LogoutButton(),
          ),
        ),

        // ── Version ─────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
              child: Text(
                'CampusPulse v1.0.0',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('À propos'),
        content: const Text(
          'CampusPulse v1.0.0\n\nApplication universitaire de suivi de planning et notifications.\n\n© 2025 UAD',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Identity Card
// ─────────────────────────────────────────────
class _ProfileIdentityCard extends StatelessWidget {
  final ProfileEntity profile;

  const _ProfileIdentityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = profile.isActive;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6750A4), Color(0xFF9068D0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6750A4).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: profile.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                        profile.avatarUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const CircularProgressIndicator(
                              strokeWidth: 2);
                        },
                      ))
                    : _AvatarInitials(initials: profile.initials),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF2DC653)
                        : colorScheme.onSurfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primaryContainer,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.75),
                      ),
                ),
                const SizedBox(height: 10),
                // Badge statut
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF2DC653)
                              : colorScheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isActive ? 'Étudiant actif' : 'Compte inactif',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  final String initials;
  const _AvatarInitials({required this.initials});

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// University Info Card
// ─────────────────────────────────────────────
class _UniversityInfoCard extends StatelessWidget {
  final ProfileEntity profile;

  const _UniversityInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations universitaires',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Matricule',
            value: profile.studentId,
            color: const Color(0xFF6750A4),
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.apartment_rounded,
            label: 'Département',
            value: profile.department,
            color: const Color(0xFF0077B6),
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.school_rounded,
            label: 'Formation',
            value: profile.program,
            color: const Color(0xFF2A9D8F),
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.military_tech_rounded,
            label: 'Niveau',
            value: profile.level,
            color: const Color(0xFFF4A261),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Toggle Settings Item
// ─────────────────────────────────────────────
class _ToggleSettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Action Settings Item
// ─────────────────────────────────────────────
class _ActionSettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ActionSettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Logout Button
// ─────────────────────────────────────────────
// lib/features/profile/presentation/pages/profile_page.dart
// Remplacer uniquement _LogoutButton

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer.withOpacity(0.4),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showLogoutDialog(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: colorScheme.error, size: 20),
              const SizedBox(width: 10),
              Text(
                'Se déconnecter',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Skeleton Loading
// ─────────────────────────────────────────────
class _ProfileSkeleton extends StatefulWidget {
  const _ProfileSkeleton();

  @override
  State<_ProfileSkeleton> createState() => _ProfileSkeletonState();
}

class _ProfileSkeletonState extends State<_ProfileSkeleton>
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),
              _SkeletonBox(height: 22, width: 80, borderRadius: 8),
              const SizedBox(height: 28),
              // Identity card skeleton
              _SkeletonBox(height: 120, borderRadius: 24),
              const SizedBox(height: 20),
              // University info skeleton
              _SkeletonBox(height: 200, borderRadius: 20),
              const SizedBox(height: 28),
              _SkeletonBox(height: 16, width: 120, borderRadius: 8),
              const SizedBox(height: 12),
              _SkeletonBox(height: 68, borderRadius: 18),
              const SizedBox(height: 8),
              _SkeletonBox(height: 68, borderRadius: 18),
              const SizedBox(height: 8),
              _SkeletonBox(height: 68, borderRadius: 18),
            ],
          ),
        ),
      ),
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
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────
class _ProfileErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_rounded,
                size: 40,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Profil introuvable',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Impossible de charger votre profil.\nVérifiez votre connexion.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

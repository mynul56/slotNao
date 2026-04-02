import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/demo_media.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RoleHubPage extends StatelessWidget {
  const RoleHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      appBar: AppBar(
        title: const Text('Choose Workspace'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
            children: [
              Text(
                user == null ? 'Welcome' : 'Hi, ${user.name}',
                style: const TextStyle(color: AppTheme.white, fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Switch between role-specific products. Each workspace has dedicated UX and permissions.',
                style: TextStyle(color: AppTheme.neutralGrey, height: 1.4),
              ),
              const SizedBox(height: 20),
              _RoleTile(
                title: 'Player App',
                subtitle: 'Search, book, pay, and join matches in seconds.',
                image: DemoMedia.turfImages.first,
                accent: AppTheme.primaryGreen,
                onTap: () => context.go(AppRoutes.home),
              ),
              const SizedBox(height: 14),
              _RoleTile(
                title: 'Owner Console',
                subtitle: 'Manage listings, schedules, and occupancy calendar.',
                image: DemoMedia.stadiumImages.first,
                accent: AppTheme.accentBlue,
                onTap: () => context.go(AppRoutes.ownerHome),
              ),
              const SizedBox(height: 14),
              _RoleTile(
                title: 'Admin Control Center',
                subtitle: 'Approve, monitor, and resolve disputes platform-wide.',
                image: DemoMedia.playerImages.first,
                accent: AppTheme.accentAmber,
                onTap: () => context.go(AppRoutes.adminHome),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final Color accent;
  final VoidCallback onTap;

  const _RoleTile({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppTheme.dark900.withValues(alpha: 0.95), AppTheme.dark900.withValues(alpha: 0.30)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accent.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'Open',
                        style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(color: AppTheme.white, fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppTheme.lightGrey, height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

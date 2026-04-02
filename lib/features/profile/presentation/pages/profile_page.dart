import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => di.sl<ProfileBloc>()..add(const ProfileLoadRequested()), child: const _ProfileView());
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.dark800,
        actions: [IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () {})],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }
          if (state is ProfileLoaded) {
            final p = state.profile;
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(p.avatarUrl, p.name, p.phone, p.role.name),
                  _buildStats(p.totalBookings, p.completedBookings),
                  const SizedBox(height: 20),
                  _buildMenuSection(context),
                ],
              ),
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: AppTheme.errorRed)),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(String? avatarUrl, String name, String phone, String role) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.dark800, AppTheme.dark700],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.dark600,
            backgroundImage: avatarUrl != null ? CachedNetworkImageProvider(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 28, color: AppTheme.primaryGreen, fontWeight: FontWeight.w700),
                  )
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.white),
                ),
                const SizedBox(height: 4),
                Text(phone, style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 14)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int total, int completed) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.dark700,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dark500),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', '$total', Icons.calendar_month_rounded),
          Container(width: 1, height: 40, color: AppTheme.dark500),
          _statItem('Completed', '$completed', Icons.check_circle_rounded),
          Container(width: 1, height: 40, color: AppTheme.dark500),
          _statItem('Cancelled', '${total - completed}', Icons.cancel_rounded),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryGreen, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.white),
        ),
        Text(label, style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final items = [
      _MenuItem(icon: Icons.calendar_month_rounded, title: 'My Bookings', onTap: () => context.push(AppRoutes.myBookings)),
      _MenuItem(icon: Icons.swap_horiz_rounded, title: 'Switch Workspace', onTap: () => context.go(AppRoutes.roleHub)),
      _MenuItem(icon: Icons.notifications_rounded, title: 'Notifications', onTap: () {}),
      _MenuItem(icon: Icons.help_outline_rounded, title: 'Help & Support', onTap: () {}),
      _MenuItem(icon: Icons.privacy_tip_rounded, title: 'Privacy Policy', onTap: () {}),
      _MenuItem(
        icon: Icons.logout_rounded,
        title: 'Logout',
        isDestructive: true,
        onTap: () {
          context.read<AuthBloc>().add(const AuthLogoutRequested());
          context.go(AppRoutes.login);
        },
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(color: AppTheme.dark600, height: 0),
      itemBuilder: (_, i) {
        final item = items[i];
        return ListTile(
          leading: Icon(item.icon, color: item.isDestructive ? AppTheme.errorRed : AppTheme.neutralGrey),
          title: Text(
            item.title,
            style: TextStyle(color: item.isDestructive ? AppTheme.errorRed : AppTheme.white, fontWeight: FontWeight.w500),
          ),
          trailing: item.isDestructive ? null : const Icon(Icons.chevron_right_rounded, color: AppTheme.dark500),
          onTap: item.onTap,
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({required this.icon, required this.title, required this.onTap, this.isDestructive = false});
}

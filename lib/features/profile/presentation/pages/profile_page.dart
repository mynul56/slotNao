import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
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
        actions: [IconButton(icon: const Icon(CupertinoIcons.pencil), onPressed: () => _onEditProfile(context))],
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: const TextStyle(color: AppTheme.errorRed)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileBloc>().add(const ProfileLoadRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
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
          _statItem('Total', '$total', CupertinoIcons.calendar),
          Container(width: 1, height: 40, color: AppTheme.dark500),
          _statItem('Completed', '$completed', CupertinoIcons.check_mark_circled_solid),
          Container(width: 1, height: 40, color: AppTheme.dark500),
          _statItem('Cancelled', '${total - completed}', CupertinoIcons.xmark_circle_fill),
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
      _MenuItem(icon: CupertinoIcons.calendar, title: 'My Bookings', onTap: () => context.go(AppRoutes.schedule)),
      _MenuItem(icon: CupertinoIcons.bell_fill, title: 'Notifications', onTap: () => _showNotificationsSheet(context)),
      _MenuItem(icon: CupertinoIcons.question_circle, title: 'Help & Support', onTap: () => _showHelpSheet(context)),
      _MenuItem(icon: CupertinoIcons.shield_fill, title: 'Privacy Policy', onTap: () => _showPrivacySheet(context)),
      _MenuItem(
        icon: CupertinoIcons.square_arrow_right,
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
          trailing: item.isDestructive ? null : const Icon(CupertinoIcons.chevron_right, color: AppTheme.dark500),
          onTap: item.onTap,
        );
      },
    );
  }

  void _onEditProfile(BuildContext context) {
    final state = context.read<ProfileBloc>().state;
    if (state is! ProfileLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile is still loading, please wait.')));
      return;
    }

    final nameController = TextEditingController(text: state.profile.name);
    final emailController = TextEditingController(text: state.profile.email);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.dark800,
          title: const Text('Edit Profile', style: TextStyle(color: AppTheme.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppTheme.white),
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                style: const TextStyle(color: AppTheme.white),
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                if (name.isEmpty || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and email are required.')));
                  return;
                }
                context.read<ProfileBloc>().add(ProfileUpdateRequested(name: name, email: email));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    _showInfoSheet(
      context: context,
      title: 'Notifications',
      body: 'No new alerts right now. Booking updates and payment alerts will appear here in realtime.',
      icon: CupertinoIcons.bell_fill,
    );
  }

  void _showHelpSheet(BuildContext context) {
    _showInfoSheet(
      context: context,
      title: 'Help & Support',
      body: 'Need help? Contact support@slotnao.app or call +880-1700-000000 from 9 AM to 11 PM.',
      icon: CupertinoIcons.question_circle,
    );
  }

  void _showPrivacySheet(BuildContext context) {
    _showInfoSheet(
      context: context,
      title: 'Privacy Policy',
      body:
          'We only use your profile and booking data to provide core app services. No sensitive data is sold to third parties.',
      icon: CupertinoIcons.shield_fill,
    );
  }

  void _showInfoSheet({required BuildContext context, required String title, required String body, required IconData icon}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.dark800,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppTheme.primaryGreen),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(body, style: const TextStyle(color: AppTheme.neutralGrey, height: 1.5)),
            ],
          ),
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

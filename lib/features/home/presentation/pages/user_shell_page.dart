import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/glass_bottom_navbar.dart';

class UserShellPage extends StatelessWidget {
  final Widget child;
  final String location;

  const UserShellPage({super.key, required this.child, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      body: child,
      bottomNavigationBar: GlassBottomNavbar(
        currentIndex: _indexFromLocation(location),
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }

  int _indexFromLocation(String value) {
    if (value.startsWith(AppRoutes.explore)) return 1;
    if (value.startsWith(AppRoutes.schedule) || value.startsWith(AppRoutes.myBookings)) return 2;
    if (value.startsWith(AppRoutes.wallet)) return 3;
    if (value.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        return;
      case 1:
        context.go(AppRoutes.explore);
        return;
      case 2:
        context.go(AppRoutes.schedule);
        return;
      case 3:
        context.go(AppRoutes.wallet);
        return;
      case 4:
        context.go(AppRoutes.profile);
        return;
    }
  }
}

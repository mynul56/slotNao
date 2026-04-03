import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class UserTabPlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const UserTabPlaceholderPage({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      appBar: AppBar(title: Text(title), backgroundColor: AppTheme.dark800),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: AppTheme.primaryGreen),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: AppTheme.white, fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: AppTheme.neutralGrey)),
          ],
        ),
      ),
    );
  }
}

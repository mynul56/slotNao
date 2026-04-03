import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class GlassBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassBottomNavbar({super.key, required this.currentIndex, required this.onTap});

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.grid_view_rounded, label: 'Explore'),
    (icon: Icons.calendar_month_rounded, label: 'Schedule'),
    (icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppTheme.dark900.withValues(alpha: 0.50),
                border: Border.all(color: AppTheme.lightGrey.withValues(alpha: 0.16), width: 1),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.30), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final isActive = index == currentIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    constraints: BoxConstraints(minWidth: isActive ? 100 : 48),
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppTheme.primaryGreenLight.withValues(alpha: 0.95), AppTheme.primaryGreen],
                            )
                          : null,
                      color: isActive ? null : Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(
                        color: isActive
                            ? AppTheme.primaryGreenLight.withValues(alpha: 0.52)
                            : Colors.white.withValues(alpha: 0.20),
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.36),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(27),
                      onTap: () => onTap(index),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(item.icon, size: 23, color: Colors.white),
                            if (isActive) ...[
                              const SizedBox(width: 10),
                              Text(
                                item.label,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

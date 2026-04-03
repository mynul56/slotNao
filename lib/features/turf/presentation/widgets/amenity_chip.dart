import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_theme.dart';

class AmenityChip extends StatelessWidget {
  final String label;
  const AmenityChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.dark600,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.dark500, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconForAmenity(label), color: AppTheme.primaryGreen, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: AppTheme.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  IconData _iconForAmenity(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('park')) return CupertinoIcons.car_detailed;
    if (lower.contains('shower') || lower.contains('changing')) {
      return CupertinoIcons.drop_fill;
    }
    if (lower.contains('light') || lower.contains('flood')) {
      return CupertinoIcons.lightbulb_fill;
    }
    if (lower.contains('cafe') || lower.contains('canteen')) {
      return CupertinoIcons.bag_fill;
    }
    if (lower.contains('wifi')) return CupertinoIcons.wifi;
    if (lower.contains('cctv') || lower.contains('security')) {
      return CupertinoIcons.shield_fill;
    }
    if (lower.contains('toilet') || lower.contains('wash')) {
      return CupertinoIcons.person;
    }
    return CupertinoIcons.check_mark_circled_solid;
  }
}

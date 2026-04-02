import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/booking_entity.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback? onCancel;

  const BookingCard({super.key, required this.booking, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (booking.status) {
      BookingStatus.confirmed => AppTheme.primaryGreen,
      BookingStatus.cancelled => AppTheme.errorRed,
      BookingStatus.completed => AppTheme.accentBlue,
      _ => AppTheme.neutralGrey,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.dark700.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dark500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.turfName,
                  style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.name.capitalized,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${booking.slotStart.toDisplayDate()}  ${booking.slotStart.toDisplayTime()} - ${booking.slotEnd.toDisplayTime()}',
            style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BDT ${booking.totalAmount.toInt()}',
                style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              if (booking.isCancellable && onCancel != null)
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.errorRed)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class BookingConfirmationPage extends StatelessWidget {
  final String bookingId;
  const BookingConfirmationPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (_, val, child) {
                  return Transform.scale(scale: val, child: child);
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppTheme.primaryGreen,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your turf slot has been booked.\nBooking ID: #${bookingId.substring(0, 8).toUpperCase()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.neutralGrey,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.dark700,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppTheme.primaryGreen, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please arrive 10 minutes before your slot. Show this confirmation at the entrance.',
                        style: TextStyle(
                          color: AppTheme.neutralGrey,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.myBookings),
                child: const Text('View My Bookings'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

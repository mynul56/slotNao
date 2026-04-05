import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/responsive/app_responsive.dart';
import '../../../../injection_container.dart' as di;
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<BookingBloc>()..add(const BookingListRequested(page: 1)),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatelessWidget {
  const _WalletView();

  @override
  Widget build(BuildContext context) {
    final horizontal = AppResponsive.horizontalPadding(context);
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      appBar: AppBar(title: const Text('Wallet'), backgroundColor: AppTheme.dark800),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (state is BookingError) {
            return _WalletErrorState(
              message: state.message,
              onRetry: () => context.read<BookingBloc>().add(const BookingListRequested(page: 1)),
            );
          }

          final bookings = state is BookingListLoaded ? state.bookings : const <BookingEntity>[];
          if (bookings.isEmpty) {
            return _WalletEmptyState(onActionTap: () => context.go(AppRoutes.home));
          }

          final analytics = _WalletAnalytics.fromBookings(bookings);
          return RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () async => context.read<BookingBloc>().add(const BookingListRequested(page: 1)),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 120),
              children: [
                _BalanceCard(analytics: analytics),
                const SizedBox(height: 14),
                _AnalyticsRow(analytics: analytics),
                const SizedBox(height: 20),
                const Text(
                  'Quick Actions',
                  style: TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                _QuickActionTile(
                  title: 'My Booking Invoices',
                  subtitle: 'Track paid and pending booking totals',
                  icon: CupertinoIcons.doc_plaintext,
                  onTap: () => context.go(AppRoutes.myBookings),
                ),
                const SizedBox(height: 10),
                _QuickActionTile(
                  title: 'Promo Credits',
                  subtitle: 'Use promo credits on your next payment',
                  icon: CupertinoIcons.gift,
                  trailing: Text(
                    '৳${analytics.promoCredits.toStringAsFixed(0)}',
                    style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Recent Transactions',
                  style: TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ...bookings.take(8).map((booking) => _TransactionTile(booking: booking)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final _WalletAnalytics analytics;

  const _BalanceCard({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: <Color>[Color(0xFF153C1D), Color(0xFF0D2613)]),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Paid', style: TextStyle(color: AppTheme.lightGrey, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            '৳${analytics.totalPaid.toStringAsFixed(0)}',
            style: const TextStyle(color: AppTheme.white, fontSize: 30, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Upcoming due: ৳${analytics.upcomingDue.toStringAsFixed(0)}',
            style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  final _WalletAnalytics analytics;

  const _AnalyticsRow({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(label: 'This Month', value: analytics.thisMonthCount.toString()),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(label: 'Completed', value: analytics.completedCount.toString()),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(label: 'Cancelled', value: analytics.cancelledCount.toString()),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.dark700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dark500),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 11)),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _QuickActionTile({required this.title, required this.subtitle, required this.icon, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.dark700,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dark500),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 12)),
                ],
              ),
            ),
            trailing ?? const Icon(CupertinoIcons.chevron_right, size: 16, color: AppTheme.neutralGrey),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final BookingEntity booking;

  const _TransactionTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM, hh:mm a');
    final isCancelled = booking.status == BookingStatus.cancelled;
    final amountColor = isCancelled ? AppTheme.errorRed : AppTheme.primaryGreen;
    final amountSign = isCancelled ? '-' : '+';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.dark700,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dark500),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(color: amountColor.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(10)),
            child: Icon(isCancelled ? CupertinoIcons.arrow_down : CupertinoIcons.arrow_up, color: amountColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.turfName,
                  style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(formatter.format(booking.createdAt), style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountSign৳${booking.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(color: amountColor, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(booking.status.name.toUpperCase(), style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletAnalytics {
  final double totalPaid;
  final double upcomingDue;
  final int thisMonthCount;
  final int completedCount;
  final int cancelledCount;
  final double promoCredits;

  const _WalletAnalytics({
    required this.totalPaid,
    required this.upcomingDue,
    required this.thisMonthCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.promoCredits,
  });

  factory _WalletAnalytics.fromBookings(List<BookingEntity> bookings) {
    final now = DateTime.now();
    final paidStatuses = <BookingStatus>{BookingStatus.confirmed, BookingStatus.completed};
    final totalPaid = bookings
        .where((booking) => paidStatuses.contains(booking.status))
        .fold<double>(0, (sum, booking) => sum + booking.totalAmount);

    final upcomingDue = bookings
        .where(
          (booking) =>
              booking.status == BookingStatus.pending ||
              (booking.status == BookingStatus.confirmed && booking.slotStart.isAfter(now)),
        )
        .fold<double>(0, (sum, booking) => sum + booking.totalAmount);

    final thisMonthCount = bookings
        .where((booking) => booking.createdAt.year == now.year && booking.createdAt.month == now.month)
        .length;

    final completedCount = bookings.where((booking) => booking.status == BookingStatus.completed).length;
    final cancelledCount = bookings.where((booking) => booking.status == BookingStatus.cancelled).length;

    return _WalletAnalytics(
      totalPaid: totalPaid,
      upcomingDue: upcomingDue,
      thisMonthCount: thisMonthCount,
      completedCount: completedCount,
      cancelledCount: cancelledCount,
      promoCredits: (completedCount * 12).toDouble(),
    );
  }
}

class _WalletEmptyState extends StatelessWidget {
  final VoidCallback onActionTap;

  const _WalletEmptyState({required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.creditcard, color: AppTheme.neutralGrey, size: 54),
            const SizedBox(height: 10),
            const Text(
              'No wallet activity yet',
              style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Book a turf and your payment timeline will appear here automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.neutralGrey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onActionTap, child: const Text('Explore Turfs')),
          ],
        ),
      ),
    );
  }
}

class _WalletErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _WalletErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: AppTheme.errorRed, size: 48),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.neutralGrey),
            ),
            const SizedBox(height: 14),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

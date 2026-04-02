import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/booking_entity.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          di.sl<BookingBloc>()..add(const BookingListRequested()),
      child: Scaffold(
        backgroundColor: AppTheme.dark900,
        appBar: AppBar(
          title: const Text('My Bookings'),
          backgroundColor: AppTheme.dark800,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primaryGreen,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: AppTheme.neutralGrey,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen),
              );
            }
            if (state is BookingListLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(state.bookings
                      .where((b) => b.status == BookingStatus.confirmed)
                      .toList()),
                  _buildList(state.bookings
                      .where((b) => b.status == BookingStatus.completed)
                      .toList()),
                  _buildList(state.bookings
                      .where((b) => b.status == BookingStatus.cancelled)
                      .toList()),
                ],
              );
            }
            if (state is BookingError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildList(List<BookingEntity> bookings) {
    if (bookings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded,
                color: AppTheme.dark500, size: 56),
            SizedBox(height: 12),
            Text('No bookings here',
                style: TextStyle(color: AppTheme.neutralGrey)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _bookingCard(context, bookings[i]),
    );
  }

  Widget _bookingCard(BuildContext context, BookingEntity booking) {
    final statusColor = switch (booking.status) {
      BookingStatus.confirmed => AppTheme.primaryGreen,
      BookingStatus.cancelled => AppTheme.errorRed,
      BookingStatus.completed => AppTheme.accentBlue,
      _ => AppTheme.neutralGrey,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.dark700,
        borderRadius: BorderRadius.circular(16),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.name.capitalized,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  color: AppTheme.neutralGrey, size: 14),
              const SizedBox(width: 6),
              Text(
                booking.slotStart.toDisplayDate(),
                style: const TextStyle(
                    color: AppTheme.neutralGrey, fontSize: 13),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded,
                  color: AppTheme.neutralGrey, size: 14),
              const SizedBox(width: 6),
              Text(
                '${booking.slotStart.toDisplayTime()} – ${booking.slotEnd.toDisplayTime()}',
                style:
                    const TextStyle(color: AppTheme.neutralGrey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '৳${booking.totalAmount.toInt()}',
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (booking.isCancellable)
                TextButton(
                  onPressed: () {
                    context
                        .read<BookingBloc>()
                        .add(BookingCancelRequested(booking.id));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                  ),
                  child: const Text('Cancel'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

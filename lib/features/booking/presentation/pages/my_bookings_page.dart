import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/booking_entity.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/booking_card.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with SingleTickerProviderStateMixin {
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
      create: (_) => di.sl<BookingBloc>()..add(const BookingListRequested()),
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
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
            }
            if (state is BookingListLoaded) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildList(state.bookings.where((b) => b.status == BookingStatus.confirmed).toList()),
                  _buildList(state.bookings.where((b) => b.status == BookingStatus.completed).toList()),
                  _buildList(state.bookings.where((b) => b.status == BookingStatus.cancelled).toList()),
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
            Icon(CupertinoIcons.calendar, color: AppTheme.dark500, size: 56),
            SizedBox(height: 12),
            Text('No bookings here', style: TextStyle(color: AppTheme.neutralGrey)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => BookingCard(
        booking: bookings[i],
        onCancel: bookings[i].isCancellable
            ? () => context.read<BookingBloc>().add(BookingCancelRequested(bookings[i].id))
            : null,
      ),
    );
  }
}

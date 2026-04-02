import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../injection_container.dart' as di;
import '../../../turf/domain/entities/turf_entity.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class BookingPage extends StatelessWidget {
  final String turfId;
  const BookingPage({super.key, required this.turfId});

  @override
  Widget build(BuildContext context) {
    final slot = GoRouterState.of(context).extra;
    return BlocProvider(
      create: (_) => di.sl<BookingBloc>(),
      child: _BookingView(turfId: turfId, slot: slot),
    );
  }
}

class _BookingView extends StatelessWidget {
  final String turfId;
  final dynamic slot;

  const _BookingView({required this.turfId, required this.slot});

  @override
  Widget build(BuildContext context) {
    final selectedSlot = slot is SlotEntity ? slot as SlotEntity : null;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          context.push(
            AppRoutes.payment,
            extra: {
              'bookingId': state.booking.id,
              'amount': state.booking.totalAmount,
              'slotStart': state.booking.slotStart.toIso8601String(),
            },
          );
        }
        if (state is BookingError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorRed));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.dark900,
        appBar: AppBar(title: const Text('Confirm Booking'), backgroundColor: AppTheme.dark800),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              if (selectedSlot == null || !selectedSlot.isAvailable)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'This slot is not available anymore. Please go back and pick a live slot.',
                    style: TextStyle(color: AppTheme.white),
                  ),
                ),
              if (selectedSlot != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Selected: ${selectedSlot.startTime.toDisplayDate()}  ${selectedSlot.startTime.toDisplayTime()} - ${selectedSlot.endTime.toDisplayTime()}',
                  style: const TextStyle(color: AppTheme.neutralGrey),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.white),
              ),
              const SizedBox(height: 12),
              _buildPaymentOptions(),
              const Spacer(),
              _buildConfirmButton(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final selectedSlot = slot is SlotEntity ? slot as SlotEntity : null;
    final start = selectedSlot?.startTime ?? DateTime.now();
    final end = selectedSlot?.endTime ?? DateTime.now().add(const Duration(hours: 1));
    final amount = selectedSlot?.price.toInt() ?? 500;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.dark700,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dark500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.white),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.dark500),
          const SizedBox(height: 12),
          _summaryRow('Date', start.toDisplayDate()),
          const SizedBox(height: 8),
          _summaryRow('Time', '${start.toDisplayTime()} — ${end.toDisplayTime()}'),
          const SizedBox(height: 8),
          _summaryRow('Duration', '${end.difference(start).inHours} hour'),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.dark500),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.white),
              ),
              Text(
                '৳$amount',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(color: AppTheme.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        _paymentOption('bKash', Icons.payment_rounded, AppTheme.errorRed),
        const SizedBox(height: 8),
        _paymentOption('Nagad', Icons.account_balance_wallet_rounded, AppTheme.warningOrange),
        const SizedBox(height: 8),
        _paymentOption('Card', Icons.credit_card_rounded, AppTheme.accentBlue),
      ],
    );
  }

  Widget _paymentOption(String name, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.dark700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dark500),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Radio<String>(value: name, groupValue: 'bKash', onChanged: (_) {}, activeColor: AppTheme.primaryGreen),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final selectedSlot = slot is SlotEntity ? slot as SlotEntity : null;

        return ElevatedButton(
          onPressed: state is BookingLoading || selectedSlot == null || !selectedSlot.isAvailable
              ? null
              : () {
                  context.read<BookingBloc>().add(
                    BookingCreateRequested(
                      turfId: turfId,
                      slotId: selectedSlot.id,
                      slotStart: selectedSlot.startTime,
                      slotEnd: selectedSlot.endTime,
                    ),
                  );
                },
          child: state is BookingLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.dark900),
                )
              : const Text('Continue To Payment'),
        );
      },
    );
  }
}

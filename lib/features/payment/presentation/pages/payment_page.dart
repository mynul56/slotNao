import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/payment_entity.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> extra;
  const PaymentPage({super.key, required this.extra});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<PaymentBloc>(),
      child: _PaymentView(extra: extra),
    );
  }
}

class _PaymentView extends StatefulWidget {
  final Map<String, dynamic> extra;
  const _PaymentView({required this.extra});

  @override
  State<_PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<_PaymentView> {
  PaymentGateway _gateway = PaymentGateway.bkash;

  @override
  Widget build(BuildContext context) {
    final bookingId = widget.extra['bookingId'] as String?;
    final amount = (widget.extra['amount'] as num?)?.toDouble() ?? 0;

    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentInitiated) {
          context.read<PaymentBloc>().add(
            PaymentConfirmRequested(
              paymentId: state.payment.id,
              transactionId: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
            ),
          );
        }
        if (state is PaymentCompleted) {
          context.go('/home/bookings/${state.payment.bookingId}/confirm');
        }
        if (state is PaymentFailed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.dark900,
        appBar: AppBar(
          title: const Text('Payment'),
          leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.dark700,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.dark500),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking #${(bookingId ?? '').split('-').first}',
                      style: const TextStyle(color: AppTheme.neutralGrey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BDT ${amount.toInt()}',
                      style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 30),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Realtime lock active: this slot is held for 2 minutes.',
                      style: TextStyle(color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Choose payment gateway',
                style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _GatewayTile(
                label: 'bKash',
                value: PaymentGateway.bkash,
                groupValue: _gateway,
                onChanged: (v) => setState(() => _gateway = v),
              ),
              const SizedBox(height: 8),
              _GatewayTile(
                label: 'Nagad',
                value: PaymentGateway.nagad,
                groupValue: _gateway,
                onChanged: (v) => setState(() => _gateway = v),
              ),
              const SizedBox(height: 8),
              _GatewayTile(
                label: 'Card',
                value: PaymentGateway.card,
                groupValue: _gateway,
                onChanged: (v) => setState(() => _gateway = v),
              ),
              const Spacer(),
              BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  return CustomButton(
                    label: 'Pay Securely',
                    icon: Icons.lock_rounded,
                    isLoading: state is PaymentLoading,
                    onPressed: bookingId == null || state is PaymentLoading
                        ? null
                        : () {
                            context.read<PaymentBloc>().add(
                              PaymentInitRequested(bookingId: bookingId, amount: amount, gateway: _gateway),
                            );
                          },
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: bookingId == null ? null : () => context.go('/home/bookings/$bookingId/confirm'),
                child: const Text('Skip gateway in demo mode'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GatewayTile extends StatelessWidget {
  final String label;
  final PaymentGateway value;
  final PaymentGateway groupValue;
  final ValueChanged<PaymentGateway> onChanged;

  const _GatewayTile({required this.label, required this.value, required this.groupValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.dark700,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: groupValue == value ? AppTheme.primaryGreen : AppTheme.dark500),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              groupValue == value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: groupValue == value ? AppTheme.primaryGreen : AppTheme.neutralGrey,
            ),
          ],
        ),
      ),
    );
  }
}

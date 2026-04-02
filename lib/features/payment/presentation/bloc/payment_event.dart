import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

final class PaymentInitRequested extends PaymentEvent {
  final String bookingId;
  final double amount;
  final PaymentGateway gateway;
  const PaymentInitRequested({
    required this.bookingId,
    required this.amount,
    required this.gateway,
  });
  @override
  List<Object> get props => [bookingId, amount, gateway];
}

final class PaymentConfirmRequested extends PaymentEvent {
  final String paymentId;
  final String transactionId;
  const PaymentConfirmRequested({
    required this.paymentId,
    required this.transactionId,
  });
  @override
  List<Object> get props => [paymentId, transactionId];
}

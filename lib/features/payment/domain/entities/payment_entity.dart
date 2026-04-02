import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String bookingId;
  final double amount;
  final PaymentGateway gateway;
  final PaymentStatus status;
  final String? transactionId;
  final String? redirectUrl;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.gateway,
    required this.status,
    this.transactionId,
    this.redirectUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, bookingId, status, transactionId];
}

enum PaymentGateway { bkash, nagad, card, cash }

enum PaymentStatus { initiated, pending, completed, failed, refunded }

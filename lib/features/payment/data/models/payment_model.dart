import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.amount,
    required super.gateway,
    required super.status,
    super.transactionId,
    super.redirectUrl,
    required super.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      gateway: _parseGateway(json['gateway'] as String? ?? 'bkash'),
      status: _parseStatus(json['status'] as String? ?? 'initiated'),
      transactionId: json['transaction_id'] as String?,
      redirectUrl: json['redirect_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static PaymentGateway _parseGateway(String g) {
    return switch (g.toLowerCase()) {
      'nagad' => PaymentGateway.nagad,
      'card' => PaymentGateway.card,
      'cash' => PaymentGateway.cash,
      _ => PaymentGateway.bkash,
    };
  }

  static PaymentStatus _parseStatus(String s) {
    return switch (s.toLowerCase()) {
      'pending' => PaymentStatus.pending,
      'completed' => PaymentStatus.completed,
      'failed' => PaymentStatus.failed,
      'refunded' => PaymentStatus.refunded,
      _ => PaymentStatus.initiated,
    };
  }
}

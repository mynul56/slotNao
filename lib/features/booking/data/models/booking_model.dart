import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.turfId,
    required super.turfName,
    required super.userId,
    required super.slotStart,
    required super.slotEnd,
    required super.totalAmount,
    required super.status,
    super.paymentId,
    required super.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      turfId: json['turf_id'] as String,
      turfName: json['turf_name'] as String? ?? '',
      userId: json['user_id'] as String,
      slotStart: DateTime.parse(json['slot_start'] as String),
      slotEnd: DateTime.parse(json['slot_end'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: _parseStatus(json['status'] as String? ?? 'pending'),
      paymentId: json['payment_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static BookingStatus _parseStatus(String status) {
    return switch (status.toLowerCase()) {
      'confirmed' => BookingStatus.confirmed,
      'cancelled' => BookingStatus.cancelled,
      'completed' => BookingStatus.completed,
      'no_show' => BookingStatus.noShow,
      _ => BookingStatus.pending,
    };
  }
}

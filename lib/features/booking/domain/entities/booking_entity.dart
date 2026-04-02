import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String turfId;
  final String turfName;
  final String userId;
  final DateTime slotStart;
  final DateTime slotEnd;
  final double totalAmount;
  final BookingStatus status;
  final String? paymentId;
  final DateTime createdAt;

  const BookingEntity({
    required this.id,
    required this.turfId,
    required this.turfName,
    required this.userId,
    required this.slotStart,
    required this.slotEnd,
    required this.totalAmount,
    required this.status,
    this.paymentId,
    required this.createdAt,
  });

  bool get isCancellable {
    final hoursUntilSlot = slotStart.difference(DateTime.now()).inHours;
    return hoursUntilSlot >= 24 && status == BookingStatus.confirmed;
  }

  @override
  List<Object?> get props => [id, turfId, userId, slotStart, status];
}

enum BookingStatus { pending, confirmed, cancelled, completed, noShow }

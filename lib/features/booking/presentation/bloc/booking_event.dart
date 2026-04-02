import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_entity.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

final class BookingCreateRequested extends BookingEvent {
  final String turfId;
  final String slotId;
  final DateTime slotStart;
  final DateTime slotEnd;

  const BookingCreateRequested({
    required this.turfId,
    required this.slotId,
    required this.slotStart,
    required this.slotEnd,
  });

  @override
  List<Object> get props => [turfId, slotId, slotStart, slotEnd];
}

final class BookingListRequested extends BookingEvent {
  final BookingStatus? status;
  final int page;
  const BookingListRequested({this.status, this.page = 1});

  @override
  List<Object?> get props => [status, page];
}

final class BookingCancelRequested extends BookingEvent {
  final String bookingId;
  const BookingCancelRequested(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

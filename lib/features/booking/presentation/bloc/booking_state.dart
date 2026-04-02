import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_entity.dart';

sealed class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

final class BookingInitial extends BookingState {
  const BookingInitial();
}

final class BookingLoading extends BookingState {
  const BookingLoading();
}

final class BookingCreated extends BookingState {
  final BookingEntity booking;
  const BookingCreated(this.booking);
  @override
  List<Object> get props => [booking];
}

final class BookingListLoaded extends BookingState {
  final List<BookingEntity> bookings;
  const BookingListLoaded(this.bookings);
  @override
  List<Object> get props => [bookings];
}

final class BookingCancelled extends BookingState {
  const BookingCancelled();
}

final class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
  @override
  List<Object> get props => [message];
}

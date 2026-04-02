import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking({
    required String turfId,
    required String slotId,
    required DateTime slotStart,
    required DateTime slotEnd,
  });

  Future<Either<Failure, List<BookingEntity>>> getBookings({
    BookingStatus? status,
    int page = 1,
  });

  Future<Either<Failure, BookingEntity>> getBookingDetail(String bookingId);

  Future<Either<Failure, void>> cancelBooking(String bookingId);
}

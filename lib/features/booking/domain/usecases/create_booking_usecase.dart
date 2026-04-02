import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

// ── Create Booking ───────────────────────────────────────────────────────────
class CreateBookingParams extends Equatable {
  final String turfId;
  final String slotId;
  final DateTime slotStart;
  final DateTime slotEnd;

  const CreateBookingParams({
    required this.turfId,
    required this.slotId,
    required this.slotStart,
    required this.slotEnd,
  });

  @override
  List<Object> get props => [turfId, slotId, slotStart, slotEnd];
}

class CreateBookingUseCase implements UseCase<BookingEntity, CreateBookingParams> {
  final BookingRepository _repository;
  const CreateBookingUseCase(this._repository);

  @override
  Future<Either<Failure, BookingEntity>> call(CreateBookingParams params) {
    return _repository.createBooking(
      turfId: params.turfId,
      slotId: params.slotId,
      slotStart: params.slotStart,
      slotEnd: params.slotEnd,
    );
  }
}

// ── Get Bookings ─────────────────────────────────────────────────────────────
class GetBookingsParams extends Equatable {
  final BookingStatus? status;
  final int page;
  const GetBookingsParams({this.status, this.page = 1});

  @override
  List<Object?> get props => [status, page];
}

class GetBookingsUseCase implements UseCase<List<BookingEntity>, GetBookingsParams> {
  final BookingRepository _repository;
  const GetBookingsUseCase(this._repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(GetBookingsParams params) {
    return _repository.getBookings(status: params.status, page: params.page);
  }
}

// ── Cancel Booking ───────────────────────────────────────────────────────────
class CancelBookingUseCase implements UseCase<void, String> {
  final BookingRepository _repository;
  const CancelBookingUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(String bookingId) {
    return _repository.cancelBooking(bookingId);
  }
}

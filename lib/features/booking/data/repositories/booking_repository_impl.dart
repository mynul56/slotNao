import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDatasource _remoteDatasource;
  const BookingRepositoryImpl({required BookingRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, BookingEntity>> createBooking({
    required String turfId,
    required String slotId,
    required DateTime slotStart,
    required DateTime slotEnd,
  }) async {
    try {
      final booking = await _remoteDatasource.createBooking(
        turfId: turfId,
        slotId: slotId,
        slotStart: slotStart,
        slotEnd: slotEnd,
      );
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookings({
    BookingStatus? status,
    int page = 1,
  }) async {
    try {
      final bookings = await _remoteDatasource.getBookings(
        status: status?.name,
        page: page,
      );
      return Right(bookings);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingDetail(
      String bookingId) async {
    try {
      final booking = await _remoteDatasource.getBookingDetail(bookingId);
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await _remoteDatasource.cancelBooking(bookingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

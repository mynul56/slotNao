import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDatasource _remoteDatasource;
  const BookingRepositoryImpl({required BookingRemoteDatasource remoteDatasource}) : _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, BookingEntity>> createBooking({
    required String turfId,
    required String slotId,
    required DateTime slotStart,
    required DateTime slotEnd,
  }) async {
    if (AppConstants.frontendOnlyMode) {
      try {
        final booking = await _remoteDatasource.createBooking(
          turfId: turfId,
          slotId: slotId,
          slotStart: slotStart,
          slotEnd: slotEnd,
        );
        return Right(booking);
      } on Exception {
        final booking = DemoStore.createBooking(turfId: turfId, slotStart: slotStart, slotEnd: slotEnd);
        return Right(booking);
      }
    }

    try {
      final booking = await _remoteDatasource.createBooking(
        turfId: turfId,
        slotId: slotId,
        slotStart: slotStart,
        slotEnd: slotEnd,
      );
      return Right(booking);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookings({BookingStatus? status, int page = 1}) async {
    if (AppConstants.frontendOnlyMode) {
      try {
        final bookings = await _remoteDatasource.getBookings(status: status?.name, page: page);
        return Right(bookings);
      } on Exception {
        return Right(DemoStore.getBookings(status: status));
      }
    }

    try {
      final bookings = await _remoteDatasource.getBookings(status: status?.name, page: page);
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
  Future<Either<Failure, BookingEntity>> getBookingDetail(String bookingId) async {
    if (AppConstants.frontendOnlyMode) {
      try {
        final booking = await _remoteDatasource.getBookingDetail(bookingId);
        return Right(booking);
      } on Exception {
        final booking = DemoStore.getBookingDetail(bookingId);
        if (booking != null) {
          return Right(booking);
        }
        return const Left(NotFoundFailure(message: 'Demo booking not found'));
      }
    }

    try {
      final booking = await _remoteDatasource.getBookingDetail(bookingId);
      return Right(booking);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    if (AppConstants.frontendOnlyMode) {
      try {
        await _remoteDatasource.cancelBooking(bookingId);
        return const Right(null);
      } on Exception {
        DemoStore.cancelBooking(bookingId);
        return const Right(null);
      }
    }

    try {
      await _remoteDatasource.cancelBooking(bookingId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  static final List<BookingEntity> _demoBookings = <BookingEntity>[];

  final BookingRemoteDatasource _remoteDatasource;
  const BookingRepositoryImpl({required BookingRemoteDatasource remoteDatasource}) : _remoteDatasource = remoteDatasource;

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
    } on NetworkException catch (e) {
      if (AppConstants.frontendOnlyMode) {
        final booking = BookingEntity(
          id: 'demo-booking-${DateTime.now().millisecondsSinceEpoch}',
          turfId: turfId,
          turfName: 'Demo Turf',
          userId: 'demo-user-1',
          slotStart: slotStart,
          slotEnd: slotEnd,
          totalAmount: 1800,
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
        );
        _demoBookings.insert(0, booking);
        return Right(booking);
      }
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookings({BookingStatus? status, int page = 1}) async {
    try {
      final bookings = await _remoteDatasource.getBookings(status: status?.name, page: page);
      return Right(bookings);
    } on NetworkException catch (e) {
      if (AppConstants.frontendOnlyMode) {
        return Right(_demoBookings);
      }
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingDetail(String bookingId) async {
    try {
      final booking = await _remoteDatasource.getBookingDetail(bookingId);
      return Right(booking);
    } on NetworkException catch (e) {
      if (AppConstants.frontendOnlyMode) {
        final booking = _demoBookings.firstWhere(
          (b) => b.id == bookingId,
          orElse: () => BookingEntity(
            id: bookingId,
            turfId: 'turf-1',
            turfName: 'Demo Turf',
            userId: 'demo-user-1',
            slotStart: DateTime.now().add(const Duration(hours: 2)),
            slotEnd: DateTime.now().add(const Duration(hours: 3)),
            totalAmount: 1800,
            status: BookingStatus.confirmed,
            createdAt: DateTime.now(),
          ),
        );
        return Right(booking);
      }
      return Left(NetworkFailure(message: e.message));
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
    } on NetworkException catch (e) {
      if (AppConstants.frontendOnlyMode) {
        final index = _demoBookings.indexWhere((b) => b.id == bookingId);
        if (index >= 0) {
          final current = _demoBookings[index];
          _demoBookings[index] = BookingEntity(
            id: current.id,
            turfId: current.turfId,
            turfName: current.turfName,
            userId: current.userId,
            slotStart: current.slotStart,
            slotEnd: current.slotEnd,
            totalAmount: current.totalAmount,
            status: BookingStatus.cancelled,
            paymentId: current.paymentId,
            createdAt: current.createdAt,
          );
        }
        return const Right(null);
      }
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

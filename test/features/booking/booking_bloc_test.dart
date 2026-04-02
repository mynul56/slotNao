import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:turf_booking_app/core/errors/failures.dart';
import 'package:turf_booking_app/features/booking/domain/entities/booking_entity.dart';
import 'package:turf_booking_app/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:turf_booking_app/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:turf_booking_app/features/booking/presentation/bloc/booking_event.dart';
import 'package:turf_booking_app/features/booking/presentation/bloc/booking_state.dart';

class MockCreateBookingUseCase extends Mock implements CreateBookingUseCase {}
class MockGetBookingsUseCase extends Mock implements GetBookingsUseCase {}
class MockCancelBookingUseCase extends Mock implements CancelBookingUseCase {}

final tSlotStart = DateTime(2026, 6, 15, 10, 0);
final tSlotEnd = DateTime(2026, 6, 15, 11, 0);

final tBooking = BookingEntity(
  id: 'booking-001',
  turfId: 'turf-001',
  turfName: 'Dhaka Premier Turf',
  userId: 'user-001',
  slotStart: tSlotStart,
  slotEnd: tSlotEnd,
  totalAmount: 1200,
  status: BookingStatus.confirmed,
  createdAt: DateTime(2026, 6, 1),
);

void main() {
  late BookingBloc bookingBloc;
  late MockCreateBookingUseCase mockCreate;
  late MockGetBookingsUseCase mockGetList;
  late MockCancelBookingUseCase mockCancel;

  setUp(() {
    mockCreate = MockCreateBookingUseCase();
    mockGetList = MockGetBookingsUseCase();
    mockCancel = MockCancelBookingUseCase();

    bookingBloc = BookingBloc(
      createBookingUseCase: mockCreate,
      getBookingsUseCase: mockGetList,
      cancelBookingUseCase: mockCancel,
    );

    registerFallbackValue(CreateBookingParams(
      turfId: 'turf-001',
      slotId: 'slot-001',
      slotStart: tSlotStart,
      slotEnd: tSlotEnd,
    ));
    registerFallbackValue(const GetBookingsParams());
    registerFallbackValue('booking-001');
  });

  tearDown(() => bookingBloc.close());

  group('BookingBloc - Create', () {
    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingCreated] on success',
      build: () {
        when(() => mockCreate(any()))
            .thenAnswer((_) async => Right(tBooking));
        return bookingBloc;
      },
      act: (bloc) => bloc.add(BookingCreateRequested(
        turfId: 'turf-001',
        slotId: 'slot-001',
        slotStart: tSlotStart,
        slotEnd: tSlotEnd,
      )),
      expect: () => [
        const BookingLoading(),
        BookingCreated(tBooking),
      ],
    );

    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingError] on slot already taken',
      build: () {
        when(() => mockCreate(any())).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Slot already booked', statusCode: 409),
          ),
        );
        return bookingBloc;
      },
      act: (bloc) => bloc.add(BookingCreateRequested(
        turfId: 'turf-001',
        slotId: 'slot-001',
        slotStart: tSlotStart,
        slotEnd: tSlotEnd,
      )),
      expect: () => [
        const BookingLoading(),
        const BookingError('Slot already booked'),
      ],
    );
  });

  group('BookingBloc - List', () {
    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingListLoaded] on success',
      build: () {
        when(() => mockGetList(any()))
            .thenAnswer((_) async => Right([tBooking]));
        return bookingBloc;
      },
      act: (bloc) => bloc.add(const BookingListRequested()),
      expect: () => [
        const BookingLoading(),
        BookingListLoaded([tBooking]),
      ],
    );
  });

  group('BookingBloc - Cancel', () {
    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, BookingCancelled] on success',
      build: () {
        when(() => mockCancel(any()))
            .thenAnswer((_) async => const Right(null));
        return bookingBloc;
      },
      act: (bloc) => bloc.add(const BookingCancelRequested('booking-001')),
      expect: () => [
        const BookingLoading(),
        const BookingCancelled(),
      ],
    );
  });
}

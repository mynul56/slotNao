import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase _createBookingUseCase;
  final GetBookingsUseCase _getBookingsUseCase;
  final CancelBookingUseCase _cancelBookingUseCase;

  BookingBloc({
    required CreateBookingUseCase createBookingUseCase,
    required GetBookingsUseCase getBookingsUseCase,
    required CancelBookingUseCase cancelBookingUseCase,
  })  : _createBookingUseCase = createBookingUseCase,
        _getBookingsUseCase = getBookingsUseCase,
        _cancelBookingUseCase = cancelBookingUseCase,
        super(const BookingInitial()) {
    on<BookingCreateRequested>(_onCreate);
    on<BookingListRequested>(_onList);
    on<BookingCancelRequested>(_onCancel);
  }

  Future<void> _onCreate(
    BookingCreateRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _createBookingUseCase(CreateBookingParams(
      turfId: event.turfId,
      slotId: event.slotId,
      slotStart: event.slotStart,
      slotEnd: event.slotEnd,
    ));
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (booking) => emit(BookingCreated(booking)),
    );
  }

  Future<void> _onList(
    BookingListRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _getBookingsUseCase(
      GetBookingsParams(status: event.status, page: event.page),
    );
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(BookingListLoaded(bookings)),
    );
  }

  Future<void> _onCancel(
    BookingCancelRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    final result = await _cancelBookingUseCase(event.bookingId);
    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (_) => emit(const BookingCancelled()),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/init_payment_usecase.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final InitPaymentUseCase _initPaymentUseCase;
  final ConfirmPaymentUseCase _confirmPaymentUseCase;

  PaymentBloc({required InitPaymentUseCase initPaymentUseCase, required ConfirmPaymentUseCase confirmPaymentUseCase})
    : _initPaymentUseCase = initPaymentUseCase,
      _confirmPaymentUseCase = confirmPaymentUseCase,
      super(const PaymentInitial()) {
    on<PaymentInitRequested>(_onInit);
    on<PaymentConfirmRequested>(_onConfirm);
  }

  Future<void> _onInit(PaymentInitRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());
    final result = await _initPaymentUseCase(
      InitPaymentParams(bookingId: event.bookingId, amount: event.amount, gateway: event.gateway),
    );
    result.fold((failure) => emit(PaymentFailed(failure.message)), (payment) => emit(PaymentInitiated(payment)));
  }

  Future<void> _onConfirm(PaymentConfirmRequested event, Emitter<PaymentState> emit) async {
    emit(const PaymentLoading());
    final result = await _confirmPaymentUseCase(
      ConfirmPaymentParams(paymentId: event.paymentId, transactionId: event.transactionId),
    );
    result.fold((failure) => emit(PaymentFailed(failure.message)), (payment) => emit(PaymentCompleted(payment)));
  }
}

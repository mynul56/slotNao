import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

// ── Init Payment ─────────────────────────────────────────────────────────────
class InitPaymentParams extends Equatable {
  final String bookingId;
  final double amount;
  final PaymentGateway gateway;

  const InitPaymentParams({
    required this.bookingId,
    required this.amount,
    required this.gateway,
  });

  @override
  List<Object> get props => [bookingId, amount, gateway];
}

class InitPaymentUseCase implements UseCase<PaymentEntity, InitPaymentParams> {
  final PaymentRepository _repository;
  const InitPaymentUseCase(this._repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(InitPaymentParams params) {
    return _repository.initPayment(
      bookingId: params.bookingId,
      amount: params.amount,
      gateway: params.gateway,
    );
  }
}

// ── Confirm Payment ──────────────────────────────────────────────────────────
class ConfirmPaymentParams extends Equatable {
  final String paymentId;
  final String transactionId;

  const ConfirmPaymentParams({
    required this.paymentId,
    required this.transactionId,
  });

  @override
  List<Object> get props => [paymentId, transactionId];
}

class ConfirmPaymentUseCase
    implements UseCase<PaymentEntity, ConfirmPaymentParams> {
  final PaymentRepository _repository;
  const ConfirmPaymentUseCase(this._repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(ConfirmPaymentParams params) {
    return _repository.confirmPayment(
      paymentId: params.paymentId,
      transactionId: params.transactionId,
    );
  }
}

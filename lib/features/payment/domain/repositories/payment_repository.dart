import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentEntity>> initPayment({
    required String bookingId,
    required double amount,
    required PaymentGateway gateway,
  });

  Future<Either<Failure, PaymentEntity>> confirmPayment({
    required String paymentId,
    required String transactionId,
  });

  Future<Either<Failure, List<PaymentEntity>>> getPaymentHistory();
}

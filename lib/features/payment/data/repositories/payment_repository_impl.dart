import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDatasource _remoteDatasource;
  const PaymentRepositoryImpl({required PaymentRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, PaymentEntity>> initPayment({
    required String bookingId,
    required double amount,
    required PaymentGateway gateway,
  }) async {
    try {
      final payment = await _remoteDatasource.initPayment(
        bookingId: bookingId,
        amount: amount,
        gateway: gateway,
      );
      return Right(payment);
    } on ServerException catch (e) {
      return Left(PaymentFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> confirmPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    try {
      final payment = await _remoteDatasource.confirmPayment(
        paymentId: paymentId,
        transactionId: transactionId,
      );
      return Right(payment);
    } on ServerException catch (e) {
      return Left(PaymentFailure(message: e.message, transactionId: transactionId));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaymentHistory() async {
    return const Right([]);
  }
}

import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_error_parser.dart';
import '../../domain/entities/payment_entity.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDatasource {
  Future<PaymentModel> initPayment({
    required String bookingId,
    required double amount,
    required PaymentGateway gateway,
  });
  Future<PaymentModel> confirmPayment({
    required String paymentId,
    required String transactionId,
  });
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  final Dio _dio;
  const PaymentRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<PaymentModel> initPayment({
    required String bookingId,
    required double amount,
    required PaymentGateway gateway,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.initPayment,
        data: {
          'booking_id': bookingId,
          'amount': amount,
          'gateway': gateway.name,
        },
      );
      return PaymentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<PaymentModel> confirmPayment({
    required String paymentId,
    required String transactionId,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.confirmPayment,
        data: {
          'payment_id': paymentId,
          'transaction_id': transactionId,
        },
      );
      return PaymentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }
}

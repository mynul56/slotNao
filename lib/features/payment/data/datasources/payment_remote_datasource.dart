import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/payment_entity.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDatasource {
  Future<PaymentModel> initPayment({required String bookingId, required double amount, required PaymentGateway gateway});
  Future<PaymentModel> confirmPayment({required String paymentId, required String transactionId});
}

class PaymentRemoteDatasourceImpl implements PaymentRemoteDatasource {
  final ApiClient _apiClient;
  const PaymentRemoteDatasourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<PaymentModel> initPayment({
    required String bookingId,
    required double amount,
    required PaymentGateway gateway,
  }) async {
    final envelope = await _apiClient.post<Map<String, dynamic>>(
      path: ApiEndpoints.initPayment,
      body: {'booking_id': bookingId, 'amount': amount, 'gateway': gateway.name},
      parser: (json) => json as Map<String, dynamic>,
      retryPost: false,
    );
    return PaymentModel.fromJson(envelope.data ?? <String, dynamic>{});
  }

  @override
  Future<PaymentModel> confirmPayment({required String paymentId, required String transactionId}) async {
    final envelope = await _apiClient.post<Map<String, dynamic>>(
      path: ApiEndpoints.confirmPayment,
      body: {'payment_id': paymentId, 'transaction_id': transactionId},
      parser: (json) => json as Map<String, dynamic>,
      retryPost: false,
    );
    return PaymentModel.fromJson(envelope.data ?? <String, dynamic>{});
  }
}

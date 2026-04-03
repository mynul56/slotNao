import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turf_booking_app/core/network/network_exceptions.dart';

void main() {
  group('NetworkExceptionMapper', () {
    test('maps timeout to TimeoutNetworkException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final mapped = NetworkExceptionMapper.fromDio(exception);
      expect(mapped, isA<TimeoutNetworkException>());
    });

    test('maps 401 to UnauthorizedNetworkException', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response<dynamic>(requestOptions: RequestOptions(path: '/test'), statusCode: 401, data: {'message': 'Unauthorized'}),
        type: DioExceptionType.badResponse,
      );

      final mapped = NetworkExceptionMapper.fromDio(exception);
      expect(mapped, isA<UnauthorizedNetworkException>());
    });
  });
}

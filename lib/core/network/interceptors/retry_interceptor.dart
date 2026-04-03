import 'dart:async';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;

  RetryInterceptor({required Dio dio, this.maxRetries = 2}) : _dio = dio;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryable = _isRetryable(err);
    if (!retryable) {
      handler.next(err);
      return;
    }

    final currentRetry = (err.requestOptions.extra['retry_count'] as int?) ?? 0;
    if (currentRetry >= maxRetries) {
      handler.next(err);
      return;
    }

    final nextRetry = currentRetry + 1;
    err.requestOptions.extra['retry_count'] = nextRetry;

    await Future<void>.delayed(Duration(milliseconds: 300 * nextRetry));

    try {
      final response = await _dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  bool _isRetryable(DioException err) {
    if (err.requestOptions.method.toUpperCase() == 'POST') {
      final explicitlyRetryable = err.requestOptions.extra['retry_post'] == true;
      if (!explicitlyRetryable) return false;
    }

    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout;
  }
}

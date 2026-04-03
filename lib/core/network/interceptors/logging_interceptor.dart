import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor({required Logger logger}) : _logger = logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kReleaseMode) {
      _logger.d('[REQ] ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (!kReleaseMode) {
      _logger.d('[RES] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kReleaseMode) {
      _logger.w('[ERR] ${err.response?.statusCode} ${err.requestOptions.uri} ${err.type.name}');
    }
    handler.next(err);
  }
}

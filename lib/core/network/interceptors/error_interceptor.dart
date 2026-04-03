import 'package:dio/dio.dart';

import '../network_exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = NetworkExceptionMapper.fromDio(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: mapped,
        message: mapped.toString(),
      ),
    );
  }
}

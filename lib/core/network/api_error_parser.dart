import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

/// Converts DioExceptions and raw status codes into typed exceptions.
class ApiErrorParser {
  ApiErrorParser._();

  static Exception parse(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException(message: 'Request timed out. Please try again.');

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _parseResponseError(err.response);

      case DioExceptionType.cancel:
        return const ServerException(message: 'Request was cancelled.', statusCode: 0);

      default:
        return const ServerException(message: 'An unexpected error occurred.', statusCode: 0);
    }
  }

  static Exception _parseResponseError(Response<dynamic>? response) {
    if (response == null) {
      return const ServerException(message: 'No response from server.');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    final message = _extractMessage(data) ?? _defaultMessage(statusCode);

    return switch (statusCode) {
      401 => AuthException(message: message, statusCode: statusCode),
      403 => AuthException(message: 'Access denied.', statusCode: statusCode),
      404 => ServerException(message: message, statusCode: statusCode),
      422 => ServerException(message: message, statusCode: statusCode, data: data),
      >= 500 => ServerException(message: 'Server error. Please try again later.', statusCode: statusCode),
      _ => ServerException(message: message, statusCode: statusCode),
    };
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String? ?? data['detail'] as String?;
    }
    return null;
  }

  static String _defaultMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'Bad request.',
      401 => 'Unauthorised. Please log in again.',
      403 => 'You do not have permission.',
      404 => 'Resource not found.',
      408 => 'Request timed out.',
      429 => 'Too many requests. Please slow down.',
      >= 500 => 'Server error. Please try again later.',
      _ => 'Something went wrong.',
    };
  }
}

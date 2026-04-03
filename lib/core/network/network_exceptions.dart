import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

sealed class AppNetworkException implements Exception {
  final String message;
  const AppNetworkException(this.message);
}

class NoInternetNetworkException extends NetworkException implements AppNetworkException {
  const NoInternetNetworkException() : super(message: 'No internet connection.');
}

class TimeoutNetworkException extends NetworkException implements AppNetworkException {
  const TimeoutNetworkException() : super(message: 'Request timeout. Please try again.');
}

class UnauthorizedNetworkException extends AuthException implements AppNetworkException {
  const UnauthorizedNetworkException({required super.message, super.statusCode});
}

class ServerNetworkException extends ServerException implements AppNetworkException {
  const ServerNetworkException({required super.message, super.statusCode, super.data});
}

class CancelledNetworkException extends ServerException implements AppNetworkException {
  const CancelledNetworkException() : super(message: 'Request was cancelled.', statusCode: 0);
}

class UnknownNetworkException extends ServerException implements AppNetworkException {
  const UnknownNetworkException({required super.message, super.statusCode, super.data});
}

class NetworkExceptionMapper {
  const NetworkExceptionMapper._();

  static Exception fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return const NoInternetNetworkException();
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutNetworkException();
      case DioExceptionType.cancel:
        return const CancelledNetworkException();
      case DioExceptionType.badResponse:
        return _fromBadResponse(e.response);
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return UnknownNetworkException(
          message: 'Unexpected network error',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
    }
  }

  static Exception _fromBadResponse(Response<dynamic>? response) {
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;
    final message = _extractMessage(data) ?? 'Request failed';

    if (statusCode == 401 || statusCode == 403) {
      return UnauthorizedNetworkException(message: message, statusCode: statusCode);
    }
    if (statusCode >= 500) {
      return ServerNetworkException(message: 'Server error. Please try again later.', statusCode: statusCode, data: data);
    }
    return ServerNetworkException(message: message, statusCode: statusCode, data: data);
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String? ?? data['detail'] as String?;
    }
    return null;
  }
}

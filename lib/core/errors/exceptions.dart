class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ServerException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection.'});

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  const AuthException({required this.message, this.statusCode});

  @override
  String toString() => 'AuthException($statusCode): $message';
}

class TokenExpiredException implements Exception {
  const TokenExpiredException();

  @override
  String toString() => 'TokenExpiredException: Access token has expired.';
}

class PaymentException implements Exception {
  final String message;
  final String? transactionId;
  const PaymentException({required this.message, this.transactionId});

  @override
  String toString() => 'PaymentException: $message';
}

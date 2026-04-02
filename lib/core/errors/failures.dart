import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Please check your network.'});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

final class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;
  const ValidationFailure({required super.message, this.fieldErrors});

  @override
  List<Object?> get props => [message, fieldErrors];
}

final class PaymentFailure extends Failure {
  final String? transactionId;
  const PaymentFailure({required super.message, this.transactionId});

  @override
  List<Object?> get props => [message, transactionId];
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.statusCode = 404});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred. Please try again.'});
}

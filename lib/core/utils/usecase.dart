import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base class for all use cases.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Use case with no parameters.
abstract class NoParamsUseCase<T> {
  Future<Either<Failure, T>> call();
}

/// Use case that returns a stream.
abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

/// Sentinel for use cases that take no parameters.
class NoParams {
  const NoParams();
}

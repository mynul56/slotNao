import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase implements NoParamsUseCase<void> {
  final AuthRepository _repository;
  const LogoutUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call() => _repository.logout();
}

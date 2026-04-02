import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase implements NoParamsUseCase<UserEntity> {
  final AuthRepository _repository;
  const GetCurrentUserUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call() => _repository.getCurrentUser();
}

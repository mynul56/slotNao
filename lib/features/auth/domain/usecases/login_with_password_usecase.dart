import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithPasswordParams extends Equatable {
  final String email;
  final String password;

  const LoginWithPasswordParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class LoginWithPasswordUseCase implements UseCase<UserEntity, LoginWithPasswordParams> {
  final AuthRepository _repository;

  const LoginWithPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginWithPasswordParams params) {
    return _repository.loginWithPassword(email: params.email, password: params.password);
  }
}

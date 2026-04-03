import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginParams extends Equatable {
  final String phone;
  final String otp;
  const LoginParams({required this.phone, required this.otp});

  @override
  List<Object> get props => [phone, otp];
}

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    return _repository.login(phone: params.phone, otp: params.otp);
  }
}

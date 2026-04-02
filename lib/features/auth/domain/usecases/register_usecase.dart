import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final String name;
  final String phone;
  final String email;
  final String password;

  const RegisterParams({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [name, phone, email, password];
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    return _repository.register(
      name: params.name,
      phone: params.phone,
      email: params.email,
      password: params.password,
    );
  }
}

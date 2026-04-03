import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SocialLoginParams extends Equatable {
  final String provider;
  final String providerToken;
  final String email;
  final String? name;

  const SocialLoginParams({required this.provider, required this.providerToken, required this.email, this.name});

  @override
  List<Object?> get props => [provider, providerToken, email, name];
}

class SocialLoginUseCase implements UseCase<UserEntity, SocialLoginParams> {
  final AuthRepository _repository;

  const SocialLoginUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SocialLoginParams params) {
    return _repository.socialLogin(
      provider: params.provider,
      providerToken: params.providerToken,
      email: params.email,
      name: params.name,
    );
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase implements NoParamsUseCase<ProfileEntity> {
  final ProfileRepository _repository;
  const GetProfileUseCase(this._repository);

  @override
  Future<Either<Failure, ProfileEntity>> call() => _repository.getProfile();
}

class UpdateProfileParams {
  final String? name;
  final String? email;
  final String? avatarUrl;
  const UpdateProfileParams({this.name, this.email, this.avatarUrl});
}

class UpdateProfileUseCase implements UseCase<ProfileEntity, UpdateProfileParams> {
  final ProfileRepository _repository;
  const UpdateProfileUseCase(this._repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      name: params.name,
      email: params.email,
      avatarUrl: params.avatarUrl,
    );
  }
}

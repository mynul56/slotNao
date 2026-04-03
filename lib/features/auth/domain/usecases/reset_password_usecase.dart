import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  final String email;
  final String token;
  final String newPassword;

  const ResetPasswordParams({
    required this.email,
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, token, newPassword];
}

class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository _repository;
  const ResetPasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      email: params.email,
      token: params.token,
      newPassword: params.newPassword,
    );
  }
}

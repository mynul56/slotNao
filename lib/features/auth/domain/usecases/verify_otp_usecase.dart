import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams extends Equatable {
  final String email;
  final String otp;
  const VerifyOtpParams({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

class VerifyOtpUseCase implements UseCase<void, VerifyOtpParams> {
  final AuthRepository _repository;
  const VerifyOtpUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(email: params.email, otp: params.otp);
  }
}

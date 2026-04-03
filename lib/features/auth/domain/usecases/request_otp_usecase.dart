import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

class RequestOtpParams extends Equatable {
  final String phone;

  const RequestOtpParams({required this.phone});

  @override
  List<Object> get props => [phone];
}

class RequestOtpUseCase implements UseCase<void, RequestOtpParams> {
  final AuthRepository _repository;

  const RequestOtpUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(RequestOtpParams params) {
    return _repository.requestOtp(phone: params.phone);
  }
}

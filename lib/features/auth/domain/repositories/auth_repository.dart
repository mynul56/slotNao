import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({required String email, required String password});

  Future<Either<Failure, UserEntity>> socialLogin({
    required String provider,
    required String providerToken,
    required String email,
    String? name,
  });

  Future<Either<Failure, UserEntity>> register({
    required String name,
    String? phone,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, void>> forgotPassword(String email);

  Future<Either<Failure, void>> resetPassword({required String email, required String token, required String newPassword});

  Future<Either<Failure, void>> verifyOtp({required String email, required String otp});
}

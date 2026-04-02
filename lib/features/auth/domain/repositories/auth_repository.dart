import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, void>> forgotPassword(String phone);

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, void>> verifyOtp({
    required String phone,
    required String otp,
  });
}

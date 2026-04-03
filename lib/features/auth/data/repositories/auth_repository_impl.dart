import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  static UserEntity? _frontendSessionUser;

  final AuthRemoteDatasource _remoteDatasource;
  final FlutterSecureStorage _secureStorage;

  const AuthRepositoryImpl({required AuthRemoteDatasource remoteDatasource, required FlutterSecureStorage secureStorage})
    : _remoteDatasource = remoteDatasource,
      _secureStorage = secureStorage;

  @override
  Future<Either<Failure, void>> verifyOtp({required String email, required String otp}) async {
    if (AppConstants.frontendOnlyMode) {
      return const Right(null);
    }
    try {
      await _remoteDatasource.verifyOtp(email: email, otp: otp);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({required String email, required String password}) async {
    if (AppConstants.frontendOnlyMode) {
      final user = _demoUser(email: email);
      _frontendSessionUser = user;
      return Right(user);
    }
    try {
      final user = await _remoteDatasource.login(email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> socialLogin({
    required String provider,
    required String providerToken,
    required String email,
    String? name,
  }) async {
    if (AppConstants.frontendOnlyMode) {
      final user = _demoUser(email: email, name: name ?? 'Demo User');
      _frontendSessionUser = user;
      return Right(user);
    }
    try {
      final user = await _remoteDatasource.socialLogin(
        provider: provider,
        providerToken: providerToken,
        email: email,
        name: name,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    String? phone,
    required String email,
    required String password,
  }) async {
    if (AppConstants.frontendOnlyMode) {
      return Right(_demoUser(email: email, name: name, phone: phone));
    }
    try {
      final user = await _remoteDatasource.register(name: name, phone: phone, email: email, password: password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (AppConstants.frontendOnlyMode) {
      _frontendSessionUser = null;
      await _secureStorage.deleteAll();
      return const Right(null);
    }
    try {
      await _remoteDatasource.logout();
      return const Right(null);
    } catch (_) {
      // Always clear local data even if server call fails
      await _secureStorage.deleteAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    if (AppConstants.frontendOnlyMode) {
      final user = _frontendSessionUser;
      if (user == null) {
        return const Left(AuthFailure(message: 'No active demo session'));
      }
      return Right(user);
    }
    try {
      final user = await _remoteDatasource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    if (AppConstants.frontendOnlyMode) {
      return const Right(null);
    }
    try {
      await _remoteDatasource.forgotPassword(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    if (AppConstants.frontendOnlyMode) {
      return const Right(null);
    }
    try {
      await _remoteDatasource.resetPassword(email: email, token: token, newPassword: newPassword);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  UserEntity _demoUser({required String email, String name = 'Demo User', String? phone}) {
    return UserEntity(
      id: 'demo-user-1',
      name: name,
      email: email,
      phone: phone ?? '01700000000',
      role: UserRole.player,
      createdAt: DateTime.now(),
    );
  }
}

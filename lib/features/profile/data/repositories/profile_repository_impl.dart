import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/demo/demo_store.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _remoteDatasource;
  const ProfileRepositoryImpl({required ProfileRemoteDatasource remoteDatasource}) : _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    if (AppConstants.frontendOnlyMode) {
      return Right(DemoStore.getProfile());
    }

    try {
      final profile = await _remoteDatasource.getProfile();
      return Right(profile);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({String? name, String? email, String? avatarUrl}) async {
    if (AppConstants.frontendOnlyMode) {
      return Right(DemoStore.updateProfile(name: name, email: email, avatarUrl: avatarUrl));
    }

    try {
      final profile = await _remoteDatasource.updateProfile(name: name, email: email, avatarUrl: avatarUrl);
      return Right(profile);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

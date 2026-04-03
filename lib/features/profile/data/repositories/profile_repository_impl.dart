import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _remoteDatasource;
  const ProfileRepositoryImpl({required ProfileRemoteDatasource remoteDatasource}) : _remoteDatasource = remoteDatasource;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final profile = await _remoteDatasource.getProfile();
      return Right(profile);
    } on NetworkException catch (e) {
      if (AppConstants.frontendOnlyMode) {
        return const Right(
          ProfileEntity(
            id: 'demo-user-1',
            name: 'Demo User',
            phone: '01700000000',
            email: 'demo@slotnao.com',
            role: UserRole.player,
            totalBookings: 12,
            completedBookings: 9,
          ),
        );
      }
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({String? name, String? email, String? avatarUrl}) async {
    try {
      final profile = await _remoteDatasource.updateProfile(name: name, email: email, avatarUrl: avatarUrl);
      return Right(profile);
    } on NetworkException catch (e) {
      if (AppConstants.frontendOnlyMode) {
        return Right(
          ProfileEntity(
            id: 'demo-user-1',
            name: name ?? 'Demo User',
            phone: '01700000000',
            email: email ?? 'demo@slotnao.com',
            avatarUrl: avatarUrl,
            role: UserRole.player,
            totalBookings: 12,
            completedBookings: 9,
          ),
        );
      }
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}

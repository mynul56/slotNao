import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/ws_client.dart';
import '../../domain/entities/turf_entity.dart';
import '../../domain/repositories/turf_repository.dart';
import '../datasources/turf_remote_datasource.dart';
import '../models/turf_model.dart';

class TurfRepositoryImpl implements TurfRepository {
  final TurfRemoteDatasource _remoteDatasource;
  final WsClient _wsClient;

  const TurfRepositoryImpl({required TurfRemoteDatasource remoteDatasource, required WsClient wsClient})
    : _remoteDatasource = remoteDatasource,
      _wsClient = wsClient;

  @override
  Future<Either<Failure, List<TurfEntity>>> getTurfs({int page = 1, int pageSize = 20}) async {
    try {
      final turfs = await _remoteDatasource.getTurfs(page: page, pageSize: pageSize);
      return Right(turfs);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TurfEntity>> getTurfDetail(String turfId) async {
    try {
      final turf = await _remoteDatasource.getTurfDetail(turfId);
      return Right(turf);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<TurfEntity>>> searchTurfs({
    required String query,
    TurfType? type,
    double? maxPrice,
    double? lat,
    double? lng,
    double? radiusKm,
  }) async {
    try {
      final turfs = await _remoteDatasource.searchTurfs(query: query);
      return Right(turfs);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<SlotEntity>>> getTurfSlots({required String turfId, required DateTime date}) async {
    try {
      final slots = await _remoteDatasource.getTurfSlots(turfId: turfId, date: date);
      return Right(slots);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Stream<Either<Failure, List<SlotEntity>>> watchSlotAvailability({required String turfId, required DateTime date}) async* {
    // Initial HTTP load
    final initial = await getTurfSlots(turfId: turfId, date: date);
    yield initial;

    // WebSocket live updates
    final path = '?turfId=$turfId&date=${date.toIso8601String().split('T')[0]}';
    final stream = await _wsClient.connect(path);
    if (stream == null) return;

    await for (final message in stream) {
      try {
        final data = jsonDecode(message as String) as Map<String, dynamic>;
        if (data['type'] == 'slot_update') {
          final list = (data['slots'] as List).map((e) => SlotModel.fromJson(e as Map<String, dynamic>)).toList();
          yield Right(list);
        }
      } catch (_) {
        // ignore malformed WS messages
      }
    }
  }
}

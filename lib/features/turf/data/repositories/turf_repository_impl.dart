import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/demo_media.dart';
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
      if (AppConstants.frontendOnlyMode) {
        return Right(_demoTurfs());
      }
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
      if (AppConstants.frontendOnlyMode) {
        return Right(_demoTurfs().firstWhere((t) => t.id == turfId, orElse: () => _demoTurfs().first));
      }
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
      if (AppConstants.frontendOnlyMode) {
        final items = _demoTurfs()
            .where(
              (t) =>
                  t.name.toLowerCase().contains(query.toLowerCase()) ||
                  t.address.toLowerCase().contains(query.toLowerCase()),
            )
            .toList(growable: false);
        return Right(items);
      }
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
      if (AppConstants.frontendOnlyMode) {
        return Right(_demoSlots(turfId, date));
      }
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

  List<TurfEntity> _demoTurfs() {
    return [
      const TurfModel(
        id: 'turf-1',
        ownerId: 'owner-1',
        name: 'SlotNao Arena Dhanmondi',
        description: 'Premium 5-a-side football turf with floodlights and seating.',
        address: 'Dhanmondi 27, Dhaka',
        latitude: 23.7465,
        longitude: 90.3760,
        type: TurfType.football,
        pricePerHour: 1800,
        amenities: ['Floodlights', 'Parking', 'Changing Room'],
        imageUrls: DemoMedia.turfImages,
        rating: 4.7,
        reviewCount: 124,
        isAvailable: true,
      ),
      const TurfModel(
        id: 'turf-2',
        ownerId: 'owner-2',
        name: 'Green Field Uttara',
        description: 'Spacious synthetic turf ideal for evening games.',
        address: 'Sector 7, Uttara, Dhaka',
        latitude: 23.8759,
        longitude: 90.3795,
        type: TurfType.multipurpose,
        pricePerHour: 1500,
        amenities: ['Drinking Water', 'Washroom', 'Cafeteria'],
        imageUrls: DemoMedia.stadiumImages,
        rating: 4.5,
        reviewCount: 89,
        isAvailable: true,
      ),
    ];
  }

  List<SlotEntity> _demoSlots(String turfId, DateTime date) {
    final base = DateTime(date.year, date.month, date.day, 16);
    return List<SlotEntity>.generate(8, (i) {
      final start = base.add(Duration(hours: i));
      final status = (i == 2 || i == 5) ? SlotStatus.booked : SlotStatus.available;
      return SlotModel(
        id: 'slot-$turfId-$i',
        turfId: turfId,
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
        status: status,
        price: 1600 + (i.isEven ? 0 : 200),
      );
    });
  }
}

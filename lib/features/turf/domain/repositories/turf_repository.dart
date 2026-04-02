import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/turf_entity.dart';

abstract class TurfRepository {
  Future<Either<Failure, List<TurfEntity>>> getTurfs({
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, TurfEntity>> getTurfDetail(String turfId);

  Future<Either<Failure, List<TurfEntity>>> searchTurfs({
    required String query,
    TurfType? type,
    double? maxPrice,
    double? lat,
    double? lng,
    double? radiusKm,
  });

  Future<Either<Failure, List<SlotEntity>>> getTurfSlots({
    required String turfId,
    required DateTime date,
  });

  Stream<Either<Failure, List<SlotEntity>>> watchSlotAvailability({
    required String turfId,
    required DateTime date,
  });
}

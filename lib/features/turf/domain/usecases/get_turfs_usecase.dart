import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/turf_entity.dart';
import '../repositories/turf_repository.dart';

// ── Get Turfs ────────────────────────────────────────────────────────────────
class GetTurfsParams {
  final int page;
  final int pageSize;
  const GetTurfsParams({this.page = 1, this.pageSize = 20});
}

class GetTurfsUseCase implements UseCase<List<TurfEntity>, GetTurfsParams> {
  final TurfRepository _repository;
  const GetTurfsUseCase(this._repository);

  @override
  Future<Either<Failure, List<TurfEntity>>> call(GetTurfsParams params) {
    return _repository.getTurfs(page: params.page, pageSize: params.pageSize);
  }
}

// ── Get Turf Detail ──────────────────────────────────────────────────────────
class GetTurfDetailUseCase implements UseCase<TurfEntity, String> {
  final TurfRepository _repository;
  const GetTurfDetailUseCase(this._repository);

  @override
  Future<Either<Failure, TurfEntity>> call(String turfId) {
    return _repository.getTurfDetail(turfId);
  }
}

// ── Search Turfs ─────────────────────────────────────────────────────────────
class SearchTurfsParams {
  final String query;
  final TurfType? type;
  final double? maxPrice;
  final double? lat;
  final double? lng;
  final double? radiusKm;

  const SearchTurfsParams({
    required this.query,
    this.type,
    this.maxPrice,
    this.lat,
    this.lng,
    this.radiusKm,
  });
}

class SearchTurfsUseCase implements UseCase<List<TurfEntity>, SearchTurfsParams> {
  final TurfRepository _repository;
  const SearchTurfsUseCase(this._repository);

  @override
  Future<Either<Failure, List<TurfEntity>>> call(SearchTurfsParams params) {
    return _repository.searchTurfs(
      query: params.query,
      type: params.type,
      maxPrice: params.maxPrice,
      lat: params.lat,
      lng: params.lng,
      radiusKm: params.radiusKm,
    );
  }
}

// ── Watch Slot Availability ───────────────────────────────────────────────────
class WatchSlotParams {
  final String turfId;
  final DateTime date;
  const WatchSlotParams({required this.turfId, required this.date});
}

class WatchSlotAvailabilityUseCase
    implements StreamUseCase<List<SlotEntity>, WatchSlotParams> {
  final TurfRepository _repository;
  const WatchSlotAvailabilityUseCase(this._repository);

  @override
  Stream<Either<Failure, List<SlotEntity>>> call(WatchSlotParams params) {
    return _repository.watchSlotAvailability(
      turfId: params.turfId,
      date: params.date,
    );
  }
}

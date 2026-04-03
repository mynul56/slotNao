import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/turf_model.dart';

abstract class TurfRemoteDatasource {
  Future<List<TurfModel>> getTurfs({int page = 1, int pageSize = 20});
  Future<TurfModel> getTurfDetail(String turfId);
  Future<List<TurfModel>> searchTurfs({required String query});
  Future<List<SlotModel>> getTurfSlots({required String turfId, required DateTime date});
}

class TurfRemoteDatasourceImpl implements TurfRemoteDatasource {
  final ApiClient _apiClient;
  const TurfRemoteDatasourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<TurfModel>> getTurfs({int page = 1, int pageSize = 20}) async {
    final paginated = await _apiClient.getPaginated<TurfModel>(
      path: ApiEndpoints.turfs,
      itemParser: (e) => TurfModel.fromJson(e as Map<String, dynamic>),
      page: page,
      pageSize: pageSize,
      cacheTtlSeconds: 30,
    );
    return paginated.items;
  }

  @override
  Future<TurfModel> getTurfDetail(String turfId) async {
    final envelope = await _apiClient.get<Map<String, dynamic>>(
      path: ApiEndpoints.turfById(turfId),
      parser: (json) => json as Map<String, dynamic>,
      requestKey: 'turf-detail-$turfId',
      cacheTtlSeconds: 60,
    );
    return TurfModel.fromJson(envelope.data ?? <String, dynamic>{});
  }

  @override
  Future<List<TurfModel>> searchTurfs({required String query}) async {
    final envelope = await _apiClient.get<List<TurfModel>>(
      path: ApiEndpoints.searchTurfs,
      parser: (json) {
        final list = json as List<dynamic>;
        return list.map((e) => TurfModel.fromJson(e as Map<String, dynamic>)).toList(growable: false);
      },
      queryParameters: {'q': query},
      requestKey: 'turf-search-$query',
      cancelPrevious: true,
      cacheTtlSeconds: 15,
    );
    return envelope.data ?? const <TurfModel>[];
  }

  @override
  Future<List<SlotModel>> getTurfSlots({required String turfId, required DateTime date}) async {
    final dateKey = date.toIso8601String().split('T')[0];
    final envelope = await _apiClient.get<List<SlotModel>>(
      path: ApiEndpoints.turfSlots(turfId),
      queryParameters: {'date': dateKey},
      requestKey: 'turf-slots-$turfId-$dateKey',
      cacheTtlSeconds: 10,
      parser: (json) {
        final list = json as List<dynamic>;
        return list.map((e) => SlotModel.fromJson(e as Map<String, dynamic>)).toList(growable: false);
      },
    );
    return envelope.data ?? const <SlotModel>[];
  }
}

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_error_parser.dart';
import '../models/turf_model.dart';

abstract class TurfRemoteDatasource {
  Future<List<TurfModel>> getTurfs({int page = 1, int pageSize = 20});
  Future<TurfModel> getTurfDetail(String turfId);
  Future<List<TurfModel>> searchTurfs({required String query});
  Future<List<SlotModel>> getTurfSlots({required String turfId, required DateTime date});
}

class TurfRemoteDatasourceImpl implements TurfRemoteDatasource {
  final Dio _dio;
  const TurfRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<TurfModel>> getTurfs({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get(ApiEndpoints.turfs, queryParameters: {'page': page, 'page_size': pageSize});
      final mapData = response.data as Map<String, dynamic>;
      final list = mapData['data'] as List;
      return list.map((e) => TurfModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<TurfModel> getTurfDetail(String turfId) async {
    try {
      final response = await _dio.get(ApiEndpoints.turfById(turfId));
      return TurfModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<List<TurfModel>> searchTurfs({required String query}) async {
    try {
      final response = await _dio.get(ApiEndpoints.searchTurfs, queryParameters: {'q': query});
      final mapData = response.data as Map<String, dynamic>;
      final list = mapData['data'] as List;
      return list.map((e) => TurfModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<List<SlotModel>> getTurfSlots({required String turfId, required DateTime date}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.turfSlots(turfId),
        queryParameters: {'date': date.toIso8601String().split('T')[0]},
      );
      final mapData = response.data as Map<String, dynamic>;
      final list = mapData['data'] as List;
      return list.map((e) => SlotModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }
}

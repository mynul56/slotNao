import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_error_parser.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login({required String phone, required String password});
  Future<UserModel> register({required String name, required String phone, required String email, required String password});
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  const AuthRemoteDatasourceImpl({required Dio dio, required FlutterSecureStorage secureStorage})
    : _dio = dio,
      _secureStorage = secureStorage;

  @override
  Future<UserModel> login({required String phone, required String password}) async {
    try {
      final response = await _dio.post(ApiEndpoints.login, data: {'phone': phone, 'password': password});

      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] as Map<String, dynamic>?) ?? body;
      await _saveTokens(
        accessToken: (data['accessToken'] ?? data['access_token']) as String,
        refreshToken: (data['refreshToken'] ?? data['refresh_token']) as String,
      );
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: {'name': name, 'phone': phone, 'email': email, 'password': password},
      );

      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] as Map<String, dynamic>?) ?? body;
      await _saveTokens(
        accessToken: (data['accessToken'] ?? data['access_token']) as String,
        refreshToken: (data['refreshToken'] ?? data['refresh_token']) as String,
      );
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    } finally {
      await _clearTokens();
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.profile);
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] as Map<String, dynamic>?) ?? body;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  Future<void> _saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _secureStorage.write(key: AppConstants.accessTokenKey, value: accessToken),
      _secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: AppConstants.accessTokenKey),
      _secureStorage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }
}

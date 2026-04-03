import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/app_constants.dart';
import '../api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _refreshDio;
  bool _isRefreshing = false;

  AuthInterceptor({required FlutterSecureStorage secureStorage, required Dio refreshDio})
    : _secureStorage = secureStorage,
      _refreshDio = refreshDio;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode ?? 0;
    final shouldRefresh =
        statusCode == 401 && !_isRefreshing && !err.requestOptions.path.contains(ApiEndpoints.refreshToken);

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshed = await _refreshToken();
      if (!refreshed) {
        await _clearTokens();
        handler.next(err);
        return;
      }

      final accessToken = await _secureStorage.read(key: AppConstants.accessTokenKey);
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $accessToken';

      final response = await _refreshDio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } catch (_) {
      await _clearTokens();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) return false;

    final response = await _refreshDio.post<dynamic>(ApiEndpoints.refreshToken, data: {'refreshToken': refreshToken});
    if (response.statusCode != 200) return false;

    final body = response.data as Map<String, dynamic>;
    final data = (body['data'] as Map<String, dynamic>?) ?? body;

    final newAccessToken = (data['accessToken'] ?? data['access_token']) as String?;
    final newRefreshToken = (data['refreshToken'] ?? data['refresh_token']) as String?;

    if (newAccessToken == null || newAccessToken.isEmpty) return false;

    await _secureStorage.write(key: AppConstants.accessTokenKey, value: newAccessToken);
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      await _secureStorage.write(key: AppConstants.refreshTokenKey, value: newRefreshToken);
    }

    return true;
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: AppConstants.accessTokenKey),
      _secureStorage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }
}

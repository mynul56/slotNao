import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  DioClient({required FlutterSecureStorage secureStorage, required Logger logger})
    : _secureStorage = secureStorage,
      _logger = logger {
    final baseUri = Uri.parse(AppConstants.baseUrl);
    if (baseUri.scheme != 'https') {
      throw StateError('Insecure API URL is not allowed. Use HTTPS.');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Version': AppConstants.appVersion,
          'X-Platform': 'mobile',
        },
      ),
    );
    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(_AuthInterceptor(_secureStorage, _dio, _logger));
    if (!kReleaseMode) {
      _dio.interceptors.add(_LoggingInterceptor(_logger));
    }
    _dio.interceptors.add(_ErrorInterceptor());
  }
}

/// Injects auth token and handles 401 token refresh
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  final Logger _logger;
  bool _isRefreshing = false;

  _AuthInterceptor(this._secureStorage, this._dio, this._logger);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = await _secureStorage.read(key: AppConstants.accessTokenKey);
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (e) {
        _logger.e('Token refresh failed', error: e);
        await _clearTokens();
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
    if (refreshToken == null) return false;

    final response = await _dio.post(ApiEndpoints.refreshToken, data: {'refreshToken': refreshToken});

    if (response.statusCode == 200) {
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] as Map<String, dynamic>?) ?? body;
      await _secureStorage.write(key: AppConstants.accessTokenKey, value: data['accessToken'] as String);
      if (data['refreshToken'] != null) {
        await _secureStorage.write(key: AppConstants.refreshTokenKey, value: data['refreshToken'] as String);
      }
      return true;
    }
    return false;
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }
}

/// Logs all requests and responses in debug mode
class _LoggingInterceptor extends Interceptor {
  final Logger _logger;
  _LoggingInterceptor(this._logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logger.d('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('✗ ${err.response?.statusCode} ${err.requestOptions.uri}', error: err.message);
    handler.next(err);
  }
}

/// Normalises DioExceptions into user-facing messages
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}

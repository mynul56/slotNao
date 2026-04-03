import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'network_exceptions.dart';
import 'network_info.dart';
import 'request_canceler.dart';

class ApiClient {
  final Dio _dio;
  final NetworkInfo _networkInfo;
  final RequestCanceler _requestCanceler;

  ApiClient._({required Dio dio, required NetworkInfo networkInfo, required RequestCanceler requestCanceler})
    : _dio = dio,
      _networkInfo = networkInfo,
      _requestCanceler = requestCanceler;

  factory ApiClient({
    required FlutterSecureStorage secureStorage,
    required Logger logger,
    required NetworkInfo networkInfo,
    required RequestCanceler requestCanceler,
  }) {
    final baseUri = Uri.parse(AppConstants.baseUrl);
    if (baseUri.scheme != 'https') {
      throw StateError('Insecure API URL is not allowed. Use HTTPS.');
    }

    final options = BaseOptions(
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
    );

    final dio = Dio(options);
    final refreshDio = Dio(options);

    dio.interceptors.addAll([
      AuthInterceptor(secureStorage: secureStorage, refreshDio: refreshDio),
      RetryInterceptor(dio: dio, maxRetries: 2),
      CacheInterceptor(),
      LoggingInterceptor(logger: logger),
      ErrorInterceptor(),
    ]);

    return ApiClient._(dio: dio, networkInfo: networkInfo, requestCanceler: requestCanceler);
  }

  Dio get dio => _dio;

  Future<ApiResponse<T>> get<T>({
    required String path,
    required T Function(dynamic data) parser,
    Map<String, dynamic>? queryParameters,
    String? requestKey,
    bool cancelPrevious = true,
    int? cacheTtlSeconds,
  }) async {
    await _assertConnectivity();

    final options = Options(
      extra: {
        if (cacheTtlSeconds != null) 'cache_ttl_seconds': cacheTtlSeconds,
        if (requestKey != null) 'cache_key': '$path-$queryParameters',
      },
    );

    return _execute(() async {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: requestKey != null ? _requestCanceler.tokenFor(requestKey, cancelPrevious: cancelPrevious) : null,
      );

      final envelope = ApiResponse.fromJson<T>(response.data, parser);
      _ensureSuccess(envelope);
      return envelope;
    });
  }

  Future<ApiResponse<T>> post<T>({
    required String path,
    required T Function(dynamic data) parser,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    String? requestKey,
    bool cancelPrevious = true,
    bool retryPost = false,
  }) async {
    await _assertConnectivity();

    return _execute(() async {
      final response = await _dio.post<dynamic>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(extra: {'retry_post': retryPost}),
        cancelToken: requestKey != null ? _requestCanceler.tokenFor(requestKey, cancelPrevious: cancelPrevious) : null,
      );

      final envelope = ApiResponse.fromJson<T>(response.data, parser);
      _ensureSuccess(envelope);
      return envelope;
    });
  }

  Future<ApiResponse<T>> patch<T>({
    required String path,
    required T Function(dynamic data) parser,
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    await _assertConnectivity();

    return _execute(() async {
      final response = await _dio.patch<dynamic>(path, data: body, queryParameters: queryParameters);
      final envelope = ApiResponse.fromJson<T>(response.data, parser);
      _ensureSuccess(envelope);
      return envelope;
    });
  }

  Future<void> delete({required String path, dynamic body}) async {
    await _assertConnectivity();
    await _execute(() => _dio.delete<dynamic>(path, data: body));
  }

  Future<ApiResponse<T>> uploadFile<T>({
    required String path,
    required T Function(dynamic data) parser,
    required FormData formData,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    await _assertConnectivity();

    return _execute(() async {
      final response = await _dio.post<dynamic>(path, data: formData, onSendProgress: onSendProgress);
      final envelope = ApiResponse.fromJson<T>(response.data, parser);
      _ensureSuccess(envelope);
      return envelope;
    });
  }

  Future<PaginatedResult<T>> getPaginated<T>({
    required String path,
    required T Function(dynamic data) itemParser,
    required int page,
    required int pageSize,
    Map<String, dynamic>? queryParameters,
    int? cacheTtlSeconds,
  }) async {
    final response = await get<Map<String, dynamic>>(
      path: path,
      parser: (raw) => raw as Map<String, dynamic>,
      queryParameters: {'page': page, 'page_size': pageSize, ...?queryParameters},
      cacheTtlSeconds: cacheTtlSeconds,
      requestKey: '$path-page-$page-size-$pageSize',
    );

    return PaginatedResult.fromEnvelope<T>(
      payload: {'status': response.status, 'data': response.data},
      itemParser: itemParser,
      fallbackPage: page,
      fallbackPageSize: pageSize,
    );
  }

  void cancelRequest(String requestKey) {
    _requestCanceler.cancel(requestKey);
  }

  void cancelAllRequests() {
    _requestCanceler.cancelAll();
  }

  Future<void> _assertConnectivity() async {
    if (!await _networkInfo.isConnected) {
      throw const NoInternetNetworkException();
    }
  }

  Future<R> _execute<R>(Future<R> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      final mapped = e.error;
      if (mapped is Exception) {
        throw mapped;
      }
      throw NetworkExceptionMapper.fromDio(e);
    }
  }

  void _ensureSuccess<T>(ApiResponse<T> response) {
    if (!response.status) {
      throw ServerNetworkException(message: response.message ?? 'Request failed', statusCode: 400);
    }
  }
}

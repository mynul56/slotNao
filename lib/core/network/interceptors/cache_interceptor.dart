import 'package:dio/dio.dart';

class CacheInterceptor extends Interceptor {
  final Map<String, _CacheEntry> _memoryCache = <String, _CacheEntry>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final ttlSeconds = options.extra['cache_ttl_seconds'] as int?;
    final cacheKey = options.extra['cache_key'] as String? ?? _defaultKey(options);

    if (options.method.toUpperCase() == 'GET' && ttlSeconds != null && ttlSeconds > 0) {
      final hit = _memoryCache[cacheKey];
      if (hit != null && hit.expiresAt.isAfter(DateTime.now())) {
        handler.resolve(
          Response<dynamic>(requestOptions: options, statusCode: 200, data: hit.payload, extra: {'source': 'memory_cache'}),
        );
        return;
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final ttlSeconds = options.extra['cache_ttl_seconds'] as int?;

    if (options.method.toUpperCase() == 'GET' && ttlSeconds != null && ttlSeconds > 0 && response.statusCode == 200) {
      final cacheKey = options.extra['cache_key'] as String? ?? _defaultKey(options);
      _memoryCache[cacheKey] = _CacheEntry(
        payload: response.data,
        expiresAt: DateTime.now().add(Duration(seconds: ttlSeconds)),
      );
    }

    handler.next(response);
  }

  String _defaultKey(RequestOptions options) {
    return '${options.method}:${options.path}:${options.queryParameters}';
  }
}

class _CacheEntry {
  final dynamic payload;
  final DateTime expiresAt;

  const _CacheEntry({required this.payload, required this.expiresAt});
}

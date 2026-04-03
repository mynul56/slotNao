class ApiResponse<T> {
  final bool status;
  final T? data;
  final String? message;

  const ApiResponse({required this.status, this.data, this.message});

  static ApiResponse<R> fromJson<R>(dynamic payload, R Function(dynamic json) parser) {
    if (payload is Map<String, dynamic>) {
      final status = payload['status'];
      if (status is bool) {
        return ApiResponse<R>(
          status: status,
          data: payload.containsKey('data') ? parser(payload['data']) : null,
          message: payload['message']?.toString(),
        );
      }
      return ApiResponse<R>(status: true, data: parser(payload), message: payload['message']?.toString());
    }

    return ApiResponse<R>(status: true, data: parser(payload));
  }
}

class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final bool hasMore;

  const PaginatedResult({required this.items, required this.page, required this.pageSize, required this.hasMore});

  static PaginatedResult<R> fromEnvelope<R>({
    required dynamic payload,
    required R Function(dynamic json) itemParser,
    required int fallbackPage,
    required int fallbackPageSize,
  }) {
    final map = payload as Map<String, dynamic>;
    final data = map['data'];

    if (data is List) {
      final items = data.map(itemParser).toList(growable: false);
      return PaginatedResult<R>(
        items: items,
        page: fallbackPage,
        pageSize: fallbackPageSize,
        hasMore: items.length >= fallbackPageSize,
      );
    }

    if (data is Map<String, dynamic>) {
      final listRaw = data['items'] ?? data['results'] ?? data['data'] ?? <dynamic>[];
      final list = listRaw is List ? listRaw : <dynamic>[];
      final items = list.map(itemParser).toList(growable: false);
      final page = (data['page'] as num?)?.toInt() ?? fallbackPage;
      final pageSize = (data['pageSize'] as num?)?.toInt() ?? fallbackPageSize;
      final hasMore = data['hasMore'] as bool? ?? items.length >= pageSize;
      return PaginatedResult<R>(items: items, page: page, pageSize: pageSize, hasMore: hasMore);
    }

    return PaginatedResult<R>(items: const [], page: fallbackPage, pageSize: fallbackPageSize, hasMore: false);
  }
}

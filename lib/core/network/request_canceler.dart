import 'package:dio/dio.dart';

class RequestCanceler {
  final Map<String, CancelToken> _tokens = <String, CancelToken>{};

  CancelToken tokenFor(String key, {bool cancelPrevious = true}) {
    if (cancelPrevious) {
      _tokens[key]?.cancel('Cancelled duplicate request: $key');
    }
    final token = CancelToken();
    _tokens[key] = token;
    return token;
  }

  void cancel(String key) {
    _tokens.remove(key)?.cancel('Cancelled request: $key');
  }

  void cancelAll() {
    for (final token in _tokens.values) {
      token.cancel('Cancelled all in-flight requests');
    }
    _tokens.clear();
  }
}

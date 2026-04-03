import '../constants/app_constants.dart';

class SecurityConfig {
  SecurityConfig._();

  static void validateTransportConfig() {
    final api = Uri.parse(AppConstants.baseUrl);
    final ws = Uri.parse(AppConstants.wsBaseUrl);

    if (api.scheme != 'https') {
      throw StateError('Insecure API URL is not allowed. Use HTTPS.');
    }
    if (ws.scheme != 'wss') {
      throw StateError('Insecure WebSocket URL is not allowed. Use WSS.');
    }
  }
}

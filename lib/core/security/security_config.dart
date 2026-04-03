import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';

class SecurityConfig {
  SecurityConfig._();

  static List<String> get pinnedFingerprints {
    return AppConstants.pinnedCertSha256
        .split(',')
        .map((value) => value.trim().toUpperCase().replaceAll(':', ''))
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  static void validateTransportConfig() {
    final api = Uri.parse(AppConstants.baseUrl);
    final ws = Uri.parse(AppConstants.wsBaseUrl);

    if (api.scheme != 'https') {
      throw StateError('Insecure API URL is not allowed. Use HTTPS.');
    }
    if (ws.scheme != 'wss') {
      throw StateError('Insecure WebSocket URL is not allowed. Use WSS.');
    }

    // Pinning can be relaxed in local/dev, but must exist in release.
    if (kReleaseMode && pinnedFingerprints.isEmpty) {
      throw StateError('Missing certificate fingerprint pinning in release mode.');
    }
  }
}

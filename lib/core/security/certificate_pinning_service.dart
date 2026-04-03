import 'dart:io';

import 'package:crypto/crypto.dart';

import '../constants/app_constants.dart';
import 'security_config.dart';

class CertificatePinningService {
  CertificatePinningService._();

  static Future<void> validatePinnedCertificate() async {
    final expectedPins = SecurityConfig.pinnedFingerprints;
    if (expectedPins.isEmpty) return;

    final apiUri = Uri.parse(AppConstants.baseUrl);
    final host = apiUri.host;
    final port = apiUri.hasPort ? apiUri.port : 443;

    final socket = await SecureSocket.connect(host, port, timeout: const Duration(seconds: 8));
    try {
      final certificate = socket.peerCertificate;
      if (certificate == null) {
        throw const TlsException('Unable to read peer certificate for pinning validation.');
      }

      final fingerprint = sha256.convert(certificate.der).toString().toUpperCase();
      if (!expectedPins.contains(fingerprint)) {
        throw TlsException('Certificate pinning validation failed for host: $host');
      }
    } finally {
      socket.destroy();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

import '../constants/app_constants.dart';

class DeviceSecurityService {
  DeviceSecurityService._();

  static Future<void> validateDeviceIntegrity() async {
    bool jailbroken = false;
    bool developerMode = false;

    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
      developerMode = await FlutterJailbreakDetection.developerMode;
    } catch (_) {
      // Inability to detect should not block startup in debug/profile.
      if (kReleaseMode) {
        rethrow;
      }
    }

    if (AppConstants.blockCompromisedDevices && (jailbroken || developerMode)) {
      throw StateError('This device does not meet security requirements.');
    }
  }
}

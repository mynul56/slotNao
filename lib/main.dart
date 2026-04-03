import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/security/certificate_pinning_service.dart';
import 'core/security/device_security_service.dart';
import 'core/security/security_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.dark900,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  String? startupError;
  try {
    SecurityConfig.validateTransportConfig();
    await CertificatePinningService.validatePinnedCertificate();
    await DeviceSecurityService.validateDeviceIntegrity();
    await di.initDependencies();
  } catch (e) {
    startupError = kDebugMode ? 'Startup blocked: $e' : 'Unable to start app on this device due to security policy.';
  }

  runApp(SlotNaoApp(startupError: startupError));
}

class SlotNaoApp extends StatelessWidget {
  final String? startupError;

  const SlotNaoApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      title: 'SlotNao — Turf Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: media.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: appRouter,
    );

    if (startupError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppTheme.dark900,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                startupError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()..add(const AuthCheckSessionRequested()))],
      child: app,
    );
  }
}

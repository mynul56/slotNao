import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/demo_media.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    _authSub = context.read<AuthBloc>().stream.listen((state) async {
      if (!mounted) return;
      if (state is AuthAuthenticated) {
        context.go(_postAuthRoute(state.user.role));
        return;
      }
      if (state is AuthUnauthenticated) {
        final prefs = di.sl<SharedPreferences>();
        final seenOnboarding = prefs.getBool(AppConstants.onboardingKey) ?? false;
        context.go(seenOnboarding ? AppRoutes.login : AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            DemoMedia.stadiumImages[0],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: AppTheme.dark900),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.dark900.withValues(alpha: 0.45), AppTheme.dark900.withValues(alpha: 0.92)],
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.4), blurRadius: 32, spreadRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.sports_soccer_rounded, color: AppTheme.dark900, size: 52),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SlotNao',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppTheme.white, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Book your game. Own the field.',
                      style: TextStyle(fontSize: 14, color: AppTheme.neutralGrey, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen.withValues(alpha: 0.8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _postAuthRoute(UserRole role) {
    switch (role) {
      case UserRole.owner:
        return AppRoutes.ownerHome;
      case UserRole.admin:
        return AppRoutes.adminHome;
      case UserRole.player:
        return AppRoutes.home;
    }
  }
}

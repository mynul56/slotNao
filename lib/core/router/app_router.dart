import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_shell_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/role_hub_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/booking/presentation/pages/booking_confirmation_page.dart';
import '../../features/booking/presentation/pages/booking_page.dart';
import '../../features/booking/presentation/pages/my_bookings_page.dart';
import '../../features/owner/presentation/pages/owner_shell_page.dart';
import '../../features/payment/presentation/pages/payment_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/turf/presentation/pages/turf_detail_page.dart';
import '../../features/turf/presentation/pages/turf_list_page.dart';

part 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isAuthRoute =
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.onboarding ||
        state.matchedLocation == AppRoutes.register ||
        state.matchedLocation == AppRoutes.splash;

    if (!isAuthenticated && !isAuthRoute) return AppRoutes.login;
    if (isAuthenticated && isAuthRoute && state.matchedLocation != AppRoutes.splash) {
      return AppRoutes.roleHub;
    }
    return null;
  },
  routes: [
    GoRoute(path: AppRoutes.splash, name: 'splash', builder: (_, __) => const SplashPage()),
    GoRoute(path: AppRoutes.onboarding, name: 'onboarding', builder: (_, __) => const OnboardingPage()),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) {
        final email = state.extra as String?;
        return ResetPasswordPage(email: email);
      },
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.verifyOtp,
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return OtpVerificationPage(email: email);
      },
    ),
    GoRoute(path: AppRoutes.roleHub, name: 'roleHub', builder: (_, __) => const RoleHubPage()),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (_, __) => const TurfListPage(),
      routes: [
        GoRoute(
          path: 'turf/:id',
          name: 'turfDetail',
          builder: (_, state) => TurfDetailPage(turfId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'book',
              name: 'booking',
              builder: (_, state) => BookingPage(turfId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'bookings',
          name: 'myBookings',
          builder: (_, __) => const MyBookingsPage(),
          routes: [
            GoRoute(
              path: ':bookingId/confirm',
              name: 'bookingConfirmation',
              builder: (_, state) => BookingConfirmationPage(bookingId: state.pathParameters['bookingId']!),
            ),
          ],
        ),
        GoRoute(
          path: 'payment',
          name: 'payment',
          builder: (_, state) => PaymentPage(extra: state.extra as Map<String, dynamic>),
        ),
        GoRoute(path: 'profile', name: 'profile', builder: (_, __) => const ProfilePage()),
      ],
    ),
    GoRoute(path: AppRoutes.ownerHome, name: 'ownerHome', builder: (_, __) => const OwnerShellPage()),
    GoRoute(path: AppRoutes.adminHome, name: 'adminHome', builder: (_, __) => const AdminShellPage()),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.route_rounded, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Page not found: ${state.error}'),
          TextButton(onPressed: () => context.go(AppRoutes.home), child: const Text('Go Home')),
        ],
      ),
    ),
  ),
);

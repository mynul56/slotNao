part of 'app_router.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyOtp = '/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String explore = '/home/explore';
  static const String schedule = '/home/schedule';
  static const String wallet = '/home/wallet';
  static const String turfDetail = '/home/turf/:id';
  static const String booking = '/home/turf/:id/book';
  static const String myBookings = '/home/schedule';
  static const String bookingConfirmation = '/home/bookings/:bookingId/confirm';
  static const String payment = '/home/payment';
  static const String profile = '/home/profile';
}

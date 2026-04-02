part of 'app_router.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String turfDetail = '/home/turf/:id';
  static const String booking = '/home/turf/:id/book';
  static const String myBookings = '/home/bookings';
  static const String bookingConfirmation = '/home/bookings/:bookingId/confirm';
  static const String payment = '/home/payment';
  static const String profile = '/home/profile';
}

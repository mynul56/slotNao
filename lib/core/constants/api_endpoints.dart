class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String requestOtp = '/auth/otp';

  // Profile
  static const String profile = '/users/me';
  static const String updateProfile = '/users/me';
  static const String uploadAvatar = '/users/me/avatar';
  static const String changePassword = '/users/me/change-password';

  // Turfs
  static const String turfs = '/turfs';
  static String turfById(String id) => '/turfs/$id';
  static String turfSlots(String id) => '/turfs/$id/slots';
  static String turfReviews(String id) => '/turfs/$id/reviews';
  static const String nearbyTurfs = '/turfs/nearby';
  static const String featuredTurfs = '/turfs/featured';
  static const String searchTurfs = '/turfs/search';

  // Bookings
  static const String bookings = '/bookings';
  static String bookingById(String id) => '/bookings/$id';
  static String cancelBooking(String id) => '/bookings/$id/cancel';
  static const String upcomingBookings = '/bookings/upcoming';
  static const String bookingHistory = '/bookings/history';

  // Payments
  static const String initPayment = '/payments/init';
  static const String confirmPayment = '/payments/confirm';
  static const String paymentHistory = '/payments/history';
  static String paymentById(String id) => '/payments/$id';
  static const String bkashCallback = '/payments/bkash/callback';
  static const String nagadCallback = '/payments/nagad/callback';

  // WebSocket
  static String slotAvailability(String turfId) => '/slots/$turfId/live';
  static String bookingUpdates(String userId) => '/users/$userId/bookings/live';
}

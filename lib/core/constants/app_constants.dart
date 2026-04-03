class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SlotNao';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.slotnao.turf';

  // API
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://api.slotnao.com/v1');
  static const String wsBaseUrl = String.fromEnvironment('WS_BASE_URL', defaultValue: 'wss://api.slotnao.com/ws');
  static const String pinnedCertSha256 = String.fromEnvironment('PINNED_CERT_SHA256', defaultValue: '');

  // Timeouts
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 15000;
  static const int wsReconnectDelayMs = 3000;
  static const int maxWsReconnectAttempts = 5;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String onboardingKey = 'onboarding_completed';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Booking
  static const int slotDurationMinutes = 60;
  static const int advanceBookingDays = 30;
  static const int maxCancellationHours = 24;

  // Payment
  static const String bkashMerchantId = String.fromEnvironment('BKASH_MERCHANT');
  static const String nagadMerchantId = String.fromEnvironment('NAGAD_MERCHANT');

  // Cache
  static const int turfCacheMinutes = 10;
  static const int slotCacheMinutes = 2;

  // Feature flags
  static const bool enableRealtime = true;
  static const bool enablePushNotifications = true;

  // Security hardening flags
  static const bool blockCompromisedDevices = bool.fromEnvironment('BLOCK_COMPROMISED_DEVICES', defaultValue: true);
}

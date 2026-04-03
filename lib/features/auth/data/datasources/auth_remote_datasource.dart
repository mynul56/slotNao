import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<void> requestOtp({required String email}); // Used for resend OTP if needed
  Future<void> verifyOtp({required String email, required String otp});
  Future<void> forgotPassword({required String email});
  Future<void> resetPassword({required String email, required String token, required String newPassword});
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> socialLogin({
    required String provider,
    required String providerToken,
    required String email,
    String? name,
  });
  Future<UserModel> register({required String name, String? phone, required String email, required String password});
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  const AuthRemoteDatasourceImpl({required ApiClient apiClient, required FlutterSecureStorage secureStorage})
    : _apiClient = apiClient,
      _secureStorage = secureStorage;

  @override
  Future<void> requestOtp({required String email}) async {
    await _apiClient.post<void>(
      path: ApiEndpoints.requestOtp,
      body: {'email': email},
      parser: (_) {},
      requestKey: 'auth-request-otp-$email',
      cancelPrevious: true,
      retryPost: true,
    );
  }

  @override
  Future<void> verifyOtp({required String email, required String otp}) async {
    await _apiClient.post<void>(
      path: ApiEndpoints.verifyOtp,
      body: {'email': email, 'otp': otp},
      parser: (_) {},
      requestKey: 'auth-verify-otp-$email',
      cancelPrevious: true,
      retryPost: false,
    );
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _apiClient.post<void>(
      path: ApiEndpoints.forgotPassword,
      body: {'email': email},
      parser: (_) {},
      requestKey: 'auth-forgot-password-$email',
      cancelPrevious: true,
      retryPost: false,
    );
  }

  @override
  Future<void> resetPassword({required String email, required String token, required String newPassword}) async {
    await _apiClient.post<void>(
      path: ApiEndpoints.resetPassword,
      body: {'email': email, 'token': token, 'newPassword': newPassword},
      parser: (_) {},
      requestKey: 'auth-reset-password-$email',
      cancelPrevious: true,
      retryPost: false,
    );
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final envelope = await _apiClient.post<Map<String, dynamic>>(
      path: ApiEndpoints.login,
      body: {'email': email, 'password': password},
      parser: (json) => json as Map<String, dynamic>,
      requestKey: 'auth-login-password-$email',
      cancelPrevious: true,
      retryPost: false,
    );

    final data = envelope.data ?? <String, dynamic>{};
    await _saveTokens(
      accessToken: (data['accessToken'] ?? data['access_token']) as String,
      refreshToken: (data['refreshToken'] ?? data['refresh_token']) as String,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> socialLogin({
    required String provider,
    required String providerToken,
    required String email,
    String? name,
  }) async {
    final envelope = await _apiClient.post<Map<String, dynamic>>(
      path: ApiEndpoints.socialLogin,
      body: {'provider': provider, 'providerToken': providerToken, 'email': email, if (name != null) 'name': name},
      parser: (json) => json as Map<String, dynamic>,
      requestKey: 'auth-social-$provider-$email',
      cancelPrevious: true,
      retryPost: false,
    );

    final data = envelope.data ?? <String, dynamic>{};
    await _saveTokens(
      accessToken: (data['accessToken'] ?? data['access_token']) as String,
      refreshToken: (data['refreshToken'] ?? data['refresh_token']) as String,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register({required String name, String? phone, required String email, required String password}) async {
    final envelope = await _apiClient.post<Map<String, dynamic>>(
      path: ApiEndpoints.register,
      body: {
        'name': name,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
        'email': email,
        'password': password,
      },
      parser: (json) => json as Map<String, dynamic>,
      requestKey: 'auth-register-$email',
      cancelPrevious: true,
      retryPost: false,
    );

    final data = envelope.data ?? <String, dynamic>{};
    await _saveTokens(
      accessToken: (data['accessToken'] ?? data['access_token']) as String,
      refreshToken: (data['refreshToken'] ?? data['refresh_token']) as String,
    );
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post<void>(path: ApiEndpoints.logout, parser: (_) {});
    } finally {
      await _clearTokens();
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final envelope = await _apiClient.get<Map<String, dynamic>>(
      path: ApiEndpoints.profile,
      parser: (json) => json as Map<String, dynamic>,
      requestKey: 'auth-current-user',
      cancelPrevious: true,
    );
    return UserModel.fromJson(envelope.data ?? <String, dynamic>{});
  }

  Future<void> _saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([
      _secureStorage.write(key: AppConstants.accessTokenKey, value: accessToken),
      _secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: AppConstants.accessTokenKey),
      _secureStorage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }
}

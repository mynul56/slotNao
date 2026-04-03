import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile({String? name, String? email, String? avatarUrl});
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final ApiClient _apiClient;
  const ProfileRemoteDatasourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ProfileModel> getProfile() async {
    final envelope = await _apiClient.get<Map<String, dynamic>>(
      path: ApiEndpoints.profile,
      parser: (json) => json as Map<String, dynamic>,
      requestKey: 'profile-me',
      cacheTtlSeconds: 30,
    );
    return ProfileModel.fromJson(envelope.data ?? <String, dynamic>{});
  }

  @override
  Future<ProfileModel> updateProfile({String? name, String? email, String? avatarUrl}) async {
    final envelope = await _apiClient.patch<Map<String, dynamic>>(
      path: ApiEndpoints.updateProfile,
      body: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      },
      parser: (json) => json as Map<String, dynamic>,
    );
    return ProfileModel.fromJson(envelope.data ?? <String, dynamic>{});
  }
}

import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_error_parser.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDatasource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile({String? name, String? email, String? avatarUrl});
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final Dio _dio;
  const ProfileRemoteDatasourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.profile);
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.updateProfile,
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        },
      );
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorParser.parse(e);
    }
  }
}

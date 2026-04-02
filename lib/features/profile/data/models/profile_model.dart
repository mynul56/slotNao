import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    super.avatarUrl,
    required super.role,
    required super.totalBookings,
    required super.completedBookings,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      role: _parseRole(json['role'] as String? ?? 'player'),
      totalBookings: json['total_bookings'] as int? ?? 0,
      completedBookings: json['completed_bookings'] as int? ?? 0,
    );
  }

  static UserRole _parseRole(String role) {
    return switch (role.toLowerCase()) {
      'owner' => UserRole.owner,
      'admin' => UserRole.admin,
      _ => UserRole.player,
    };
  }
}

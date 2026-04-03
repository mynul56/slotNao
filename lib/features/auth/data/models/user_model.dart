import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.avatarUrl,
    required super.role,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] ?? json['createdAt'];
    return UserModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'User').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
      role: _parseRole(json['role'] as String? ?? 'player'),
      createdAt: createdRaw is String ? DateTime.tryParse(createdRaw) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static UserRole _parseRole(String role) {
    return switch (role.toLowerCase()) {
      'owner' => UserRole.owner,
      'admin' => UserRole.admin,
      'moderator' => UserRole.admin,
      _ => UserRole.player,
    };
  }
}

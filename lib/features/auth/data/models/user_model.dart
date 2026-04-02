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
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: _parseRole(json['role'] as String? ?? 'player'),
      createdAt: DateTime.parse(json['created_at'] as String),
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
      _ => UserRole.player,
    };
  }
}

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, phone, role];
}

enum UserRole { player, owner, admin }

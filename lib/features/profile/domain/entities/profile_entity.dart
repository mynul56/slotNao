import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? avatarUrl;
  final UserRole role;
  final int totalBookings;
  final int completedBookings;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.totalBookings,
    required this.completedBookings,
  });

  @override
  List<Object?> get props => [id, phone, email];
}

import 'package:equatable/equatable.dart';

class TurfEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final double pricePerHour;
  final List<String> amenities;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final TurfType type;
  final String ownerId;

  const TurfEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.pricePerHour,
    required this.amenities,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.type,
    required this.ownerId,
  });

  @override
  List<Object?> get props => [id, name, pricePerHour, isAvailable];
}

enum TurfType { football, cricket, basketball, badminton, multipurpose }

class SlotEntity extends Equatable {
  final String id;
  final String turfId;
  final DateTime startTime;
  final DateTime endTime;
  final SlotStatus status;
  final double price;

  const SlotEntity({
    required this.id,
    required this.turfId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.price,
  });

  bool get isAvailable => status == SlotStatus.available;

  @override
  List<Object?> get props => [id, turfId, startTime, status];
}

enum SlotStatus { available, booked, blocked }

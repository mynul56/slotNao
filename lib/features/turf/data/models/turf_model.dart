import '../../domain/entities/turf_entity.dart';

class TurfModel extends TurfEntity {
  const TurfModel({
    required super.id,
    required super.name,
    required super.description,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.imageUrls,
    required super.pricePerHour,
    required super.amenities,
    required super.rating,
    required super.reviewCount,
    required super.isAvailable,
    required super.type,
    required super.ownerId,
  });

  factory TurfModel.fromJson(Map<String, dynamic> json) {
    return TurfModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrls: List<String>.from(json['image_urls'] as List? ?? []),
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] as List? ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      type: _parseType(json['type'] as String? ?? 'football'),
      ownerId: json['owner_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'image_urls': imageUrls,
        'price_per_hour': pricePerHour,
        'amenities': amenities,
        'rating': rating,
        'review_count': reviewCount,
        'is_available': isAvailable,
        'type': type.name,
        'owner_id': ownerId,
      };

  static TurfType _parseType(String type) {
    return switch (type.toLowerCase()) {
      'cricket' => TurfType.cricket,
      'basketball' => TurfType.basketball,
      'badminton' => TurfType.badminton,
      'multipurpose' => TurfType.multipurpose,
      _ => TurfType.football,
    };
  }
}

class SlotModel extends SlotEntity {
  const SlotModel({
    required super.id,
    required super.turfId,
    required super.startTime,
    required super.endTime,
    required super.status,
    required super.price,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] as String,
      turfId: json['turf_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      status: _parseStatus(json['status'] as String? ?? 'available'),
      price: (json['price'] as num).toDouble(),
    );
  }

  static SlotStatus _parseStatus(String status) {
    return switch (status.toLowerCase()) {
      'booked' => SlotStatus.booked,
      'blocked' => SlotStatus.blocked,
      _ => SlotStatus.available,
    };
  }
}

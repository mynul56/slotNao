import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/turf_entity.dart';

class TurfCard extends StatelessWidget {
  final TurfEntity turf;
  const TurfCard({super.key, required this.turf});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/turf/${turf.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.dark700,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.dark500, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            turf.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: turf.imageUrls.first,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppTheme.dark600),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.dark600,
                      child: const Icon(Icons.sports_soccer_rounded,
                          color: AppTheme.dark500, size: 48),
                    ),
                  )
                : Container(
                    color: AppTheme.dark600,
                    child: const Icon(Icons.sports_soccer_rounded,
                        color: AppTheme.dark500, size: 48),
                  ),
            // Availability badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: turf.isAvailable
                      ? AppTheme.primaryGreen.withValues(alpha: 0.9)
                      : AppTheme.errorRed.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  turf.isAvailable ? 'Available' : 'Full',
                  style: const TextStyle(
                    color: AppTheme.dark900,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Sport type badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.dark900.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  turf.type.name.titleCase,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  turf.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppTheme.accentAmber, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    turf.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppTheme.accentAmber,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    ' (${turf.reviewCount})',
                    style: const TextStyle(
                      color: AppTheme.neutralGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppTheme.primaryGreen, size: 13),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  turf.address,
                  style: const TextStyle(
                    color: AppTheme.neutralGrey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '৳${turf.pricePerHour.toInt()}/hr',
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

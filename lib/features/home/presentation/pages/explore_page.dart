import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/responsive/app_responsive.dart';
import '../../../../injection_container.dart' as di;
import '../../../turf/domain/entities/turf_entity.dart';
import '../../../turf/presentation/bloc/turf_bloc.dart';
import '../../../turf/presentation/bloc/turf_event.dart';
import '../../../turf/presentation/bloc/turf_state.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => di.sl<TurfBloc>()..add(const TurfLoadRequested()), child: const _ExploreView());
  }
}

class _ExploreView extends StatefulWidget {
  const _ExploreView();

  @override
  State<_ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<_ExploreView> {
  static const List<String> _filters = <String>['All', 'Football', 'Cricket', 'Basketball', 'Badminton'];
  String _selectedFilter = _filters.first;

  @override
  Widget build(BuildContext context) {
    final horizontal = AppResponsive.horizontalPadding(context);
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      appBar: AppBar(title: const Text('Explore'), backgroundColor: AppTheme.dark800),
      body: BlocBuilder<TurfBloc, TurfState>(
        builder: (context, state) {
          if (state is TurfLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (state is TurfError) {
            return _ErrorState(
              message: state.message,
              onRetry: () => context.read<TurfBloc>().add(const TurfLoadRequested()),
            );
          }

          final turfs = _resolveTurfs(state);
          if (turfs.isEmpty) {
            return const _EmptyState();
          }

          final filteredTurfs = _applyFilter(turfs, _selectedFilter);
          final topRatedTurfs = filteredTurfs.toList()..sort((a, b) => b.rating.compareTo(a.rating));
          return RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () async => context.read<TurfBloc>().add(const TurfLoadRequested()),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 120),
              children: [
                _HeroCard(turfCount: filteredTurfs.length),
                const SizedBox(height: 18),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final value = _filters[index];
                      final selected = value == _selectedFilter;
                      return ChoiceChip(
                        label: Text(value),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedFilter = value),
                        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        side: BorderSide(color: selected ? AppTheme.primaryGreen : AppTheme.dark500),
                        labelStyle: TextStyle(
                          color: selected ? AppTheme.primaryGreen : AppTheme.lightGrey,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Popular Near You',
                  style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 190,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filteredTurfs.take(6).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _CompactExploreCard(turf: filteredTurfs[i]),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Top Rated',
                  style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 8),
                ...topRatedTurfs.take(5).map((turf) => _TopRatedTile(turf: turf)),
              ],
            ),
          );
        },
      ),
    );
  }

  List<TurfEntity> _resolveTurfs(TurfState state) {
    return switch (state) {
      TurfListLoaded(:final turfs) => turfs,
      TurfSearchResults(:final results) => results,
      _ => <TurfEntity>[],
    };
  }

  List<TurfEntity> _applyFilter(List<TurfEntity> turfs, String selectedFilter) {
    if (selectedFilter == 'All') return turfs;
    final lookup = selectedFilter.toLowerCase();
    return turfs.where((item) => item.type.name.toLowerCase() == lookup).toList();
  }
}

class _HeroCard extends StatelessWidget {
  final int turfCount;

  const _HeroCard({required this.turfCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: <Color>[Color(0xFF174B1D), Color(0xFF0D2711)]),
        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppTheme.primaryGreen.withValues(alpha: 0.16),
            ),
            child: const Icon(CupertinoIcons.location_solid, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Nearby Availability',
                  style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '$turfCount active turfs open for booking right now.',
                  style: const TextStyle(color: AppTheme.lightGrey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactExploreCard extends StatelessWidget {
  final TurfEntity turf;

  const _CompactExploreCard({required this.turf});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppResponsive.isTablet(context) ? 280 : 250,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/home/turf/${turf.id}'),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.dark700,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dark500),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: turf.imageUrls.isEmpty
                      ? Container(
                          color: AppTheme.dark600,
                          child: const Center(
                            child: Icon(CupertinoIcons.sportscourt_fill, color: AppTheme.neutralGrey, size: 34),
                          ),
                        )
                      : CachedNetworkImage(imageUrl: turf.imageUrls.first, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turf.name,
                      style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.star_fill, color: AppTheme.accentAmber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          turf.rating.toStringAsFixed(1),
                          style: const TextStyle(color: AppTheme.accentAmber, fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          '৳${turf.pricePerHour.toInt()}/hr',
                          style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRatedTile extends StatelessWidget {
  final TurfEntity turf;

  const _TopRatedTile({required this.turf});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.push('/home/turf/${turf.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppTheme.dark700,
          border: Border.all(color: AppTheme.dark500),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.sportscourt_fill, color: AppTheme.primaryGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    turf.name,
                    style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    turf.address,
                    style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.star_fill, color: AppTheme.accentAmber, size: 13),
                    const SizedBox(width: 3),
                    Text(
                      turf.rating.toStringAsFixed(1),
                      style: const TextStyle(color: AppTheme.accentAmber, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('৳${turf.pricePerHour.toInt()}/hr', style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: AppTheme.errorRed, size: 46),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.neutralGrey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.map_pin_ellipse, color: AppTheme.neutralGrey, size: 50),
          SizedBox(height: 10),
          Text('No turfs available for explore.', style: TextStyle(color: AppTheme.neutralGrey)),
        ],
      ),
    );
  }
}

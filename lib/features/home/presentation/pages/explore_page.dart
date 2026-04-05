import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
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
  static const LatLng _defaultCenter = LatLng(23.8103, 90.4125);
  final MapController _mapController = MapController();

  TurfType? _selectedType;
  LatLng _cameraCenter = _defaultCenter;
  LatLng? _userLocation;
  String? _selectedTurfId;
  bool _isMapReady = false;
  LatLng? _pendingCenter;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      body: BlocBuilder<TurfBloc, TurfState>(
        builder: (context, state) {
          final turfs = _resolveTurfs(state);
          final visibleTurfs = _applyFilter(turfs);

          return Stack(
            children: [
              _buildMapLayer(state, visibleTurfs),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Column(children: [_buildTopSearchBar(), const SizedBox(height: 10), _buildFilterChips()]),
                ),
              ),
              _buildFloatingActions(state),
              _buildBottomSheet(state, visibleTurfs),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapLayer(TurfState state, List<TurfEntity> visibleTurfs) {
    final markers = <Marker>[
      for (final turf in visibleTurfs.where(_hasValidCoordinates))
        Marker(
          point: LatLng(turf.latitude, turf.longitude),
          width: 130,
          height: 62,
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedTurfId = turf.id);
              _mapController.move(LatLng(turf.latitude, turf.longitude), 15.5);
            },
            child: _TurfMarkerChip(turf: turf, isSelected: turf.id == _selectedTurfId),
          ),
        ),
      if (_userLocation != null)
        Marker(
          point: _userLocation!,
          width: 24,
          height: 24,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
              border: Border.all(color: AppTheme.white, width: 2),
            ),
          ),
        ),
    ];

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _cameraCenter,
        initialZoom: 13,
        minZoom: 4,
        maxZoom: 18,
        onMapReady: () {
          _isMapReady = true;
          final pending = _pendingCenter;
          if (pending != null) {
            _mapController.move(pending, 15.5);
            _pendingCenter = null;
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.slotnao.turf_booking_app',
        ),
        MarkerLayer(markers: markers),
        RichAttributionWidget(
          showFlutterMapAttribution: false,
          attributions: [
            TextSourceAttribution('OpenStreetMap contributors', onTap: () {}),
            const TextSourceAttribution('CARTO'),
          ],
        ),
        if (state is TurfLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.22),
            child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
          ),
      ],
    );
  }

  List<TurfEntity> _resolveTurfs(TurfState state) {
    return switch (state) {
      TurfListLoaded(:final turfs) => turfs,
      TurfSearchResults(:final results) => results,
      _ => <TurfEntity>[],
    };
  }

  List<TurfEntity> _applyFilter(List<TurfEntity> turfs) {
    if (_selectedType == null) return turfs;
    return turfs.where((item) => item.type == _selectedType).toList();
  }

  bool _hasValidCoordinates(TurfEntity turf) => turf.latitude != 0 && turf.longitude != 0;

  Future<void> _tryMoveToCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final current = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() {
        _userLocation = current;
        _cameraCenter = current;
      });

      if (_isMapReady) {
        _mapController.move(current, 15.5);
      } else {
        _pendingCenter = current;
      }
    } on MissingPluginException {
      // Location plugin can be unavailable right after adding dependencies until full rebuild.
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Location service is initializing. Try again after app restart.')));
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to access device location right now.')));
    } catch (_) {
      // Swallow unexpected location errors to keep Explore map functional.
    }
  }

  Widget _buildTopSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.dark800.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.dark500),
      ),
      child: const Row(
        children: [
          Icon(CupertinoIcons.search, color: AppTheme.neutralGrey),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Where do you want to play?',
              style: TextStyle(color: AppTheme.lightGrey, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Icon(CupertinoIcons.slider_horizontal_3, color: AppTheme.lightGrey),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final types = <(String label, TurfType? type)>[
      ('All', null),
      ('Football', TurfType.football),
      ('Cricket', TurfType.cricket),
      ('Basketball', TurfType.basketball),
      ('Badminton', TurfType.badminton),
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final item = types[i];
          final selected = item.$2 == _selectedType;
          return ChoiceChip(
            label: Text(item.$1),
            selected: selected,
            onSelected: (_) => setState(() => _selectedType = item.$2),
            selectedColor: AppTheme.primaryGreen,
            backgroundColor: AppTheme.dark800.withValues(alpha: 0.92),
            side: BorderSide(color: selected ? AppTheme.primaryGreen : AppTheme.dark500),
            labelStyle: TextStyle(color: selected ? AppTheme.dark900 : AppTheme.lightGrey, fontWeight: FontWeight.w600),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: types.length,
      ),
    );
  }

  Widget _buildFloatingActions(TurfState state) {
    return Positioned(
      right: 14,
      bottom: 220,
      child: Column(
        children: [
          _MapActionButton(icon: CupertinoIcons.location_solid, onTap: _tryMoveToCurrentLocation),
          const SizedBox(height: 8),
          _MapActionButton(
            icon: CupertinoIcons.refresh,
            onTap: () => context.read<TurfBloc>().add(const TurfLoadRequested()),
          ),
          if (state is TurfError) ...[const SizedBox(height: 8), const _ErrorPill()],
        ],
      ),
    );
  }

  Widget _buildBottomSheet(TurfState state, List<TurfEntity> turfs) {
    return DraggableScrollableSheet(
      minChildSize: 0.20,
      initialChildSize: 0.30,
      maxChildSize: 0.70,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.dark900,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border.all(color: AppTheme.dark600),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                height: 4,
                width: 46,
                decoration: BoxDecoration(color: AppTheme.dark500, borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      turfs.isEmpty ? 'No Nearby Turfs' : '${turfs.length} Nearby Turfs',
                      style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 18),
                    ),
                    const Spacer(),
                    if (state is TurfLoading)
                      const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGreen),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: turfs.isEmpty
                    ? const Center(
                        child: Text('Try a different sport filter.', style: TextStyle(color: AppTheme.neutralGrey)),
                      )
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 120),
                        itemCount: turfs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final turf = turfs[i];
                          return _TurfListTile(
                            turf: turf,
                            selected: turf.id == _selectedTurfId,
                            onTap: () {
                              setState(() => _selectedTurfId = turf.id);
                              if (_hasValidCoordinates(turf)) {
                                _mapController.move(LatLng(turf.latitude, turf.longitude), 15.7);
                              }
                              context.push('/home/turf/${turf.id}');
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.dark800.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.dark500),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(height: 44, width: 44, child: Icon(icon, color: AppTheme.white, size: 20)),
      ),
    );
  }
}

class _TurfMarkerChip extends StatelessWidget {
  final TurfEntity turf;
  final bool isSelected;

  const _TurfMarkerChip({required this.turf, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.dark800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.primaryGreenLight : AppTheme.dark500),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.36), blurRadius: 10)],
        ),
        child: Text(
          '৳${turf.pricePerHour.toInt()}',
          style: TextStyle(color: isSelected ? AppTheme.dark900 : AppTheme.white, fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ),
    );
  }
}

class _TurfListTile extends StatelessWidget {
  final TurfEntity turf;
  final bool selected;
  final VoidCallback onTap;

  const _TurfListTile({required this.turf, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen.withValues(alpha: 0.14) : AppTheme.dark800,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppTheme.primaryGreen : AppTheme.dark500),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(color: AppTheme.dark700, borderRadius: BorderRadius.circular(10)),
              child: const Icon(CupertinoIcons.sportscourt_fill, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    turf.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    turf.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '৳${turf.pricePerHour.toInt()}/hr',
                  style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w700, fontSize: 12),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(CupertinoIcons.star_fill, size: 12, color: AppTheme.accentAmber),
                    const SizedBox(width: 3),
                    Text(turf.rating.toStringAsFixed(1), style: const TextStyle(color: AppTheme.accentAmber, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPill extends StatelessWidget {
  const _ErrorPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.errorRed.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
      child: const Text(
        'Offline',
        style: TextStyle(color: AppTheme.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

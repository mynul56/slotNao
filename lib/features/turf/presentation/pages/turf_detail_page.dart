import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/slot_cubit.dart';
import '../bloc/turf_bloc.dart';
import '../bloc/turf_event.dart';
import '../bloc/turf_state.dart';
import '../../domain/entities/turf_entity.dart';
import '../widgets/amenity_chip.dart';
import '../widgets/slot_grid.dart';
import '../widgets/turf_image_carousel.dart';

class TurfDetailPage extends StatelessWidget {
  final String turfId;
  const TurfDetailPage({super.key, required this.turfId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<TurfBloc>()..add(TurfDetailRequested(turfId)),
        ),
        BlocProvider(create: (_) => di.sl<SlotCubit>()),
      ],
      child: _TurfDetailView(turfId: turfId),
    );
  }
}

class _TurfDetailView extends StatefulWidget {
  final String turfId;
  const _TurfDetailView({required this.turfId});

  @override
  State<_TurfDetailView> createState() => _TurfDetailViewState();
}

class _TurfDetailViewState extends State<_TurfDetailView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      body: BlocBuilder<TurfBloc, TurfState>(
        builder: (context, state) {
          if (state is TurfLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            );
          }
          if (state is TurfDetailLoaded) {
            final turf = state.turf;
            context.read<SlotCubit>().watchSlots(
                  turfId: widget.turfId,
                  date: _selectedDate,
                );
            return _buildDetail(context, turf);
          }
          if (state is TurfError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, TurfEntity turf) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppTheme.dark800,
          flexibleSpace: FlexibleSpaceBar(
            background: TurfImageCarousel(
                imageUrls: turf.imageUrls),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.dark900.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, size: 18),
            ),
            onPressed: () => context.pop(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        turf.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppTheme.accentAmber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            (turf.rating).toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppTheme.accentAmber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppTheme.primaryGreen, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        turf.address,
                        style: const TextStyle(
                          color: AppTheme.neutralGrey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '৳${(turf.pricePerHour).toInt()}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const Text(
                      ' / hour',
                      style: TextStyle(
                        color: AppTheme.neutralGrey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  turf.description,
                  style: const TextStyle(
                    color: AppTheme.neutralGrey,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (turf.amenities)
                      .map((a) => AmenityChip(label: a))
                      .toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDatePicker(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Slots',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.dark600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle,
                              color: AppTheme.primaryGreen, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'Live',
                            style: TextStyle(
                              color: AppTheme.primaryGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BlocBuilder<SlotCubit, SlotState>(
                  builder: (context, slotState) {
                    if (slotState is SlotLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGreen,
                          strokeWidth: 2,
                        ),
                      );
                    }
                    if (slotState is SlotLoaded) {
                      return SlotGrid(
                        slots: slotState.slots,
                        turfId: widget.turfId,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final now = DateTime.now();
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (_, i) {
          final date = now.add(Duration(days: i));
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              context.read<SlotCubit>().watchSlots(
                    turfId: widget.turfId,
                    date: date,
                  );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              width: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : AppTheme.dark700,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : Border.all(color: AppTheme.dark500),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekday(date),
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? AppTheme.dark900
                          : AppTheme.neutralGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? AppTheme.dark900 : AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _weekday(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/entities/turf_entity.dart';
import '../bloc/turf_bloc.dart';
import '../bloc/turf_event.dart';
import '../bloc/turf_state.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/turf_card.dart';

class TurfListPage extends StatelessWidget {
  const TurfListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<TurfBloc>()..add(const TurfLoadRequested()),
      child: const _TurfListView(),
    );
  }
}

class _TurfListView extends StatefulWidget {
  const _TurfListView();

  @override
  State<_TurfListView> createState() => _TurfListViewState();
}

class _TurfListViewState extends State<_TurfListView> {
  final _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final bloc = context.read<TurfBloc>();
    final state = bloc.state;
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        state is TurfListLoaded &&
        state.hasMore) {
      _currentPage++;
      bloc.add(TurfLoadRequested(page: _currentPage));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark900,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context),
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildTurfList(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      snap: true,
      backgroundColor: AppTheme.dark800,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_greeting()} 👋',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.neutralGrey,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Text(
              'Find Your Turf',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_rounded, color: AppTheme.white),
          onPressed: () => context.push(AppRoutes.profile),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.white),
          onPressed: () => context.push(AppRoutes.myBookings),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: SearchBarWidget(
          onChanged: (q) =>
              context.read<TurfBloc>().add(TurfSearchRequested(q)),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    const categories = ['All', 'Football', 'Cricket', 'Basketball', 'Badminton'];
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => FilterChip(
            label: Text(categories[i]),
            selected: i == 0,
            onSelected: (_) {},
            selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
            checkmarkColor: AppTheme.primaryGreen,
            labelStyle: TextStyle(
              color: i == 0 ? AppTheme.primaryGreen : AppTheme.neutralGrey,
              fontWeight: i == 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTurfList() {
    return BlocBuilder<TurfBloc, TurfState>(
      builder: (context, state) {
        if (state is TurfLoading) {
          return const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            ),
          );
        }

        if (state is TurfError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppTheme.errorRed, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: const TextStyle(color: AppTheme.neutralGrey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TurfBloc>()
                        .add(const TurfLoadRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final List<TurfEntity> turfs = switch (state) {
          TurfListLoaded(:final turfs) => turfs,
          TurfSearchResults(:final results) => results,
          _ => <TurfEntity>[],
        };

        if (turfs.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_soccer_rounded,
                      color: AppTheme.dark500, size: 64),
                  SizedBox(height: 12),
                  Text('No turfs found',
                      style: TextStyle(color: AppTheme.neutralGrey)),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.separated(
            itemCount: turfs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => TurfCard(turf: turfs[i]),
          ),
        );
      },
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

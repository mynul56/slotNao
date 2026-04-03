import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/demo_media.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/responsive/app_responsive.dart';
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
    return BlocProvider(create: (_) => di.sl<TurfBloc>()..add(const TurfLoadRequested()), child: const _TurfListView());
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
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
          _buildFindPlayersSection(),
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
              style: const TextStyle(fontSize: 12, color: AppTheme.neutralGrey, fontWeight: FontWeight.w400),
            ),
            const Text(
              'Find Your Turf',
              style: TextStyle(fontSize: 18, color: AppTheme.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.bell_fill, color: AppTheme.white),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar() {
    final horizontal = AppResponsive.horizontalPadding(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 0),
        child: SearchBarWidget(onChanged: (q) => context.read<TurfBloc>().add(TurfSearchRequested(q))),
      ),
    );
  }

  Widget _buildCategoryChips() {
    const categories = ['All', 'Football', 'Cricket', 'Basketball', 'Badminton'];
    final horizontal = AppResponsive.horizontalPadding(context);
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 8),
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
    final columns = AppResponsive.adaptiveGridColumns(context);
    final horizontal = AppResponsive.horizontalPadding(context);

    return BlocBuilder<TurfBloc, TurfState>(
      builder: (context, state) {
        if (state is TurfLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
          );
        }

        if (state is TurfError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: AppTheme.errorRed, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, style: const TextStyle(color: AppTheme.neutralGrey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TurfBloc>().add(const TurfLoadRequested()),
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
                  Icon(CupertinoIcons.sportscourt_fill, color: AppTheme.dark500, size: 64),
                  SizedBox(height: 12),
                  Text('No turfs found', style: TextStyle(color: AppTheme.neutralGrey)),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 108),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: columns >= 3 ? 0.96 : 0.92,
            ),
            delegate: SliverChildBuilderDelegate((_, i) => TurfCard(turf: turfs[i]), childCount: turfs.length),
          ),
        );
      },
    );
  }

  Widget _buildFindPlayersSection() {
    final horizontal = AppResponsive.horizontalPadding(context);
    final cardWidth = AppResponsive.isTablet(context) ? 320.0 : 250.0;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 166,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(horizontal, 4, horizontal, 0),
          scrollDirection: Axis.horizontal,
          itemCount: DemoMedia.playerImages.length,
          itemBuilder: (_, i) {
            return Container(
              width: cardWidth,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.dark500),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: DemoMedia.playerImages[i], fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppTheme.dark900.withValues(alpha: 0.92), AppTheme.dark900.withValues(alpha: 0.25)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            i == 0 ? 'Find Players Nearby' : 'Join Community Match',
                            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Skill-based teams • Instant join',
                            style: TextStyle(color: AppTheme.lightGrey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

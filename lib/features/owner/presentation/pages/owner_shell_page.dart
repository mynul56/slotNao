import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/demo_media.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class OwnerShellPage extends StatefulWidget {
  const OwnerShellPage({super.key});

  @override
  State<OwnerShellPage> createState() => _OwnerShellPageState();
}

class _OwnerShellPageState extends State<OwnerShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [_OwnerDashboard(), _OwnerTurfManagement(), _OwnerCalendar(), _OwnerBookings(), _OwnerEarnings()];

    return Scaffold(
      backgroundColor: AppTheme.dark900,
      appBar: AppBar(
        title: const Text('Owner Workspace'),
        actions: [IconButton(onPressed: () => context.go(AppRoutes.roleHub), icon: const Icon(Icons.swap_horiz_rounded))],
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.stadium_rounded), label: 'Turfs'),
          NavigationDestination(icon: Icon(Icons.calendar_month_rounded), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.list_alt_rounded), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.savings_rounded), label: 'Earnings'),
        ],
      ),
    );
  }
}

class _OwnerDashboard extends StatelessWidget {
  const _OwnerDashboard();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeroBanner(
          image: DemoMedia.stadiumImages[1],
          title: 'Prime Arena, 91% occupancy this week',
          subtitle: '12 pending requests need your confirmation.',
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _KpiCard(title: 'Today Revenue', value: 'BDT 42,500', trend: '+18%'),
            _KpiCard(title: 'Upcoming Slots', value: '48', trend: '+7%'),
            _KpiCard(title: 'Cancelled', value: '3', trend: '-2%'),
            _KpiCard(title: 'Rating', value: '4.8', trend: '+0.2'),
          ],
        ),
      ],
    );
  }
}

class _OwnerTurfManagement extends StatelessWidget {
  const _OwnerTurfManagement();

  @override
  Widget build(BuildContext context) {
    final list = List.generate(3, (i) => i);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.dark700.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dark500),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(imageUrl: DemoMedia.turfImages[i], width: 92, height: 72, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Arena ${i + 1}',
                    style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text('Dhaka • Football • BDT 2200/hr', style: TextStyle(color: AppTheme.neutralGrey)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Approved', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 11)),
                  ),
                ],
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit_rounded)),
          ],
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: list.length,
    );
  }
}

class _OwnerCalendar extends StatelessWidget {
  const _OwnerCalendar();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.dark700,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.dark500),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calendar Slot System',
                style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 17),
              ),
              SizedBox(height: 12),
              Text('Today: 06:00-08:00 blocked for maintenance', style: TextStyle(color: AppTheme.neutralGrey)),
              SizedBox(height: 8),
              Text('Peak demand: 18:00-23:00', style: TextStyle(color: AppTheme.primaryGreen)),
            ],
          ),
        ),
      ],
    );
  }
}

class _OwnerBookings extends StatelessWidget {
  const _OwnerBookings();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) => ListTile(
        tileColor: AppTheme.dark700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Booking #BK00${50 + i}', style: const TextStyle(color: AppTheme.white)),
        subtitle: const Text('Tonight 20:00-21:00 • Team Vertex', style: TextStyle(color: AppTheme.neutralGrey)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: 8,
    );
  }
}

class _OwnerEarnings extends StatelessWidget {
  const _OwnerEarnings();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.dark700,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.dark500),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monthly Payout', style: TextStyle(color: AppTheme.neutralGrey)),
              SizedBox(height: 8),
              Text(
                'BDT 7,24,500',
                style: TextStyle(color: AppTheme.white, fontSize: 30, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text('+23% vs last month', style: TextStyle(color: AppTheme.primaryGreen)),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _HeroBanner({required this.image, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(imageUrl: image, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppTheme.dark900.withValues(alpha: 0.92), AppTheme.dark900.withValues(alpha: 0.35)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: AppTheme.white, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppTheme.lightGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;

  const _KpiCard({required this.title, required this.value, required this.trend});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 42) / 2,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.dark700,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.dark500),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppTheme.neutralGrey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 22),
            ),
            const SizedBox(height: 2),
            Text(trend, style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

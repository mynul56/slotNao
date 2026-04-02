import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key});

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [_AdminDashboard(), _AdminUsers(), _AdminApprovals(), _AdminMonitoring(), _AdminDisputes()];

    return Scaffold(
      backgroundColor: AppTheme.dark900,
      appBar: AppBar(
        title: const Text('Admin Control Center'),
        actions: [IconButton(onPressed: () => context.go(AppRoutes.roleHub), icon: const Icon(Icons.swap_horiz_rounded))],
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 240), child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.space_dashboard_rounded), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.group_rounded), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.fact_check_rounded), label: 'Approvals'),
          NavigationDestination(icon: Icon(Icons.monitor_heart_rounded), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.gavel_rounded), label: 'Disputes'),
        ],
      ),
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _AdminStatCard(title: 'GMV Today', value: 'BDT 19.2L', note: '+11.8%'),
        SizedBox(height: 10),
        _AdminStatCard(title: 'Active Turfs', value: '1,204', note: '+64 this week'),
        SizedBox(height: 10),
        _AdminStatCard(title: 'Open Disputes', value: '17', note: '3 high priority'),
      ],
    );
  }
}

class _AdminUsers extends StatelessWidget {
  const _AdminUsers();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) => ListTile(
        tileColor: AppTheme.dark700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(
          backgroundColor: AppTheme.dark600,
          child: Text('${i + 1}', style: const TextStyle(color: AppTheme.white)),
        ),
        title: Text('User ID U00${i + 10}', style: const TextStyle(color: AppTheme.white)),
        subtitle: const Text('Role: Player • Verified', style: TextStyle(color: AppTheme.neutralGrey)),
        trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.block_rounded)),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: 8,
    );
  }
}

class _AdminApprovals extends StatelessWidget {
  const _AdminApprovals();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (int i = 0; i < 6; i++)
          Card(
            child: ListTile(
              title: Text('Listing #TURF-10${i + 2}', style: const TextStyle(color: AppTheme.white)),
              subtitle: const Text('Needs compliance review', style: TextStyle(color: AppTheme.neutralGrey)),
              trailing: FilledButton(onPressed: () {}, child: const Text('Approve')),
            ),
          ),
      ],
    );
  }
}

class _AdminMonitoring extends StatelessWidget {
  const _AdminMonitoring();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _AdminStatCard(title: 'Live Bookings', value: '386', note: 'Updated every 5s'),
        SizedBox(height: 10),
        _AdminStatCard(title: 'Payment Success', value: '98.4%', note: 'Stripe + bKash + Nagad'),
        SizedBox(height: 10),
        _AdminStatCard(title: 'Double Booking Alerts', value: '0', note: 'Realtime conflict guard active'),
      ],
    );
  }
}

class _AdminDisputes extends StatelessWidget {
  const _AdminDisputes();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.dark700,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.dark500),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dispute DP-20${i + 1}',
              style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text('Player reported unavailable lights at booked slot.', style: TextStyle(color: AppTheme.neutralGrey)),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('Escalate')),
                const SizedBox(width: 8),
                FilledButton(onPressed: () {}, child: const Text('Resolve')),
              ],
            ),
          ],
        ),
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: 4,
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String note;

  const _AdminStatCard({required this.title, required this.value, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.dark700,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dark500),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.neutralGrey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.w700, fontSize: 30),
          ),
          const SizedBox(height: 4),
          Text(note, style: const TextStyle(color: AppTheme.primaryGreen)),
        ],
      ),
    );
  }
}

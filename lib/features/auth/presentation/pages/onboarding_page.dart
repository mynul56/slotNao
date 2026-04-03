import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/demo_media.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../injection_container.dart' as di;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  final _slides = const [
    (
      title: 'Book in 15 Seconds',
      subtitle: 'Live slot availability, zero confusion, and one-tap booking flow.',
      image: DemoMedia.turfImages,
    ),
    (
      title: 'Run Your Turf Like a Pro',
      subtitle: 'Owner dashboard with schedule control, bookings, and earnings at a glance.',
      image: DemoMedia.stadiumImages,
    ),
    (
      title: 'Platform Intelligence',
      subtitle: 'Admin gets total platform visibility for approvals, disputes, and growth.',
      image: DemoMedia.playerImages,
    ),
  ];

  Future<void> _finish() async {
    await di.sl<SharedPreferences>().setBool(AppConstants.onboardingKey, true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_index];

    return Scaffold(
      backgroundColor: AppTheme.dark900,
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(imageUrl: slide.image[_index % slide.image.length], fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.dark900.withValues(alpha: 0.35), AppTheme.dark900.withValues(alpha: 0.94)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text('Skip', style: TextStyle(color: AppTheme.white)),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (_, i) {
                      final s = _slides[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(s.subtitle, style: const TextStyle(color: AppTheme.lightGrey, fontSize: 15, height: 1.5)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i == _index ? AppTheme.primaryGreen : AppTheme.dark500,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
                        label: _index == _slides.length - 1 ? 'Start Booking' : 'Continue',
                        onPressed: () {
                          if (_index == _slides.length - 1) {
                            _finish();
                          } else {
                            _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

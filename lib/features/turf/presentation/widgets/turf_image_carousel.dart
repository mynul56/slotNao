import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TurfImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const TurfImageCarousel({super.key, required this.imageUrls});

  @override
  State<TurfImageCarousel> createState() => _TurfImageCarouselState();
}

class _TurfImageCarouselState extends State<TurfImageCarousel> {
  int _current = 0;
  final PageController _ctrl = PageController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        color: AppTheme.dark600,
        child: const Icon(CupertinoIcons.sportscourt_fill,
            color: AppTheme.dark500, size: 64),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) => setState(() => _current = i),
          itemCount: widget.imageUrls.length,
          itemBuilder: (_, i) => CachedNetworkImage(
            imageUrl: widget.imageUrls[i],
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: AppTheme.dark600),
            errorWidget: (_, __, ___) => Container(color: AppTheme.dark600),
          ),
        ),
        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppTheme.dark900,
                  AppTheme.dark900.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        // Dots
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _current == i
                        ? AppTheme.primaryGreen
                        : AppTheme.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

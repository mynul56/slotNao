import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? radius;

  const LoadingWidget({super.key, this.height = 16, this.width, this.radius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.dark700,
      highlightColor: AppTheme.dark600,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: AppTheme.dark700, borderRadius: radius ?? BorderRadius.circular(12)),
      ),
    );
  }
}

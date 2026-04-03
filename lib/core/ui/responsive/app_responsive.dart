import 'package:flutter/material.dart';

class AppResponsive {
  AppResponsive._();

  static const double smallPhoneWidth = 360;
  static const double tabletWidth = 720;

  static bool isSmallPhone(BuildContext context) => MediaQuery.sizeOf(context).width < smallPhoneWidth;

  static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).width >= tabletWidth;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletWidth) return width * 0.08;
    if (width >= 420) return width * 0.06;
    return width * 0.05;
  }

  static double scaleText(BuildContext context, double base) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    final factor = (shortestSide / 390).clamp(0.9, 1.2);
    return base * factor;
  }

  static int adaptiveGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) return 4;
    if (width >= tabletWidth) return 3;
    return 2;
  }
}

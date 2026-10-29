import 'package:flutter/material.dart';

class ResponsiveUtil {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double maxContentWidth = 520;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double responsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > tabletBreakpoint) return baseSize * 1.25;
    if (width > mobileBreakpoint) return baseSize * 1.1;
    return baseSize;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width > tabletBreakpoint) return (width - maxContentWidth) / 2;
    if (width > mobileBreakpoint) return 48.0;
    return 20.0;
  }
}

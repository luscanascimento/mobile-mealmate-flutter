import 'package:flutter/widgets.dart';

/// Simple responsive helpers for phone vs tablet layouts.
class Responsive {
  const Responsive._();

  static const double tabletBreakpoint = 600;
  static const double largeTabletBreakpoint = 900;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Number of grid columns to use for card lists, scaled by width.
  static int gridColumns(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= largeTabletBreakpoint) return 4;
    if (width >= tabletBreakpoint) return 3;
    return 2;
  }
}

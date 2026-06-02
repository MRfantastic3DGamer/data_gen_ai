import 'package:flutter/material.dart';

/// Consistent spacing tokens used across screens.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width > 600 ? 24.0 : 16.0;
    return EdgeInsets.fromLTRB(horizontal, md, horizontal, md);
  }
}

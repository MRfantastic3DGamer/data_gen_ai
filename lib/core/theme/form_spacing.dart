import 'package:flutter/material.dart';

/// Vertical spacing between stacked form controls.
abstract final class FormSpacing {
  static const double fieldGap = 14;
  static const EdgeInsets fieldPadding = EdgeInsets.only(bottom: fieldGap);

  static Widget gap() => const SizedBox(height: fieldGap);
}

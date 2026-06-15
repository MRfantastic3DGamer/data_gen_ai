import 'package:flutter/material.dart';

/// True for phones in any orientation. Tablets use the wide three-panel layout.
bool isCompactGraphEditor(BuildContext context) {
  return MediaQuery.sizeOf(context).shortestSide < 600;
}

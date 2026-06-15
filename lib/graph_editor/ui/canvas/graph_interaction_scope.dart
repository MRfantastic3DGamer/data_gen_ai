import 'package:flutter/material.dart';

/// Coordinates pointer capture between the graph canvas and interactive children
/// (nodes, ports, blocks) so pan/zoom does not steal taps.
class GraphInteractionScope extends InheritedWidget {
  const GraphInteractionScope({
    super.key,
    required this.acquirePointer,
    required this.releasePointer,
    required this.globalToWorld,
    required this.scale,
    required super.child,
  });

  final void Function(int pointer) acquirePointer;
  final void Function(int pointer) releasePointer;
  final Offset Function(Offset global) globalToWorld;
  final double scale;

  static GraphInteractionScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<GraphInteractionScope>();
    assert(scope != null, 'GraphInteractionScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(GraphInteractionScope oldWidget) =>
      scale != oldWidget.scale;
}

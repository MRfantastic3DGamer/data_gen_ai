import 'package:data_gen_ai/graph_editor/ui/canvas/graph_interaction_scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Pan/zoom surface that does not compete with node/port pointer handlers.
class GraphTransformSurface extends StatefulWidget {
  const GraphTransformSurface({
    super.key,
    required this.controller,
    required this.child,
    this.onBackgroundTap,
  });

  final TransformationController controller;
  final Widget child;
  final VoidCallback? onBackgroundTap;

  @override
  State<GraphTransformSurface> createState() => _GraphTransformSurfaceState();
}

class _GraphTransformSurfaceState extends State<GraphTransformSurface> {
  final GlobalKey _viewportKey = GlobalKey();
  final Map<int, Offset> _activePointers = <int, Offset>{};
  final Set<int> _childClaimedPointers = <int>{};
  Offset? _panStartViewport;
  Matrix4? _matrixAtPanStart;
  double? _pinchStartDistance;
  double? _scaleAtPinchStart;
  Offset? _focalAtPinchStart;

  double get _scale => widget.controller.value.getMaxScaleOnAxis();

  Offset _globalToWorld(Offset global) {
    final box = _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return global;
    final viewportLocal = box.globalToLocal(global);
    return MatrixUtils.transformPoint(
      Matrix4.inverted(widget.controller.value),
      viewportLocal,
    );
  }

  void _acquirePointer(int pointer) =>
      setState(() => _childClaimedPointers.add(pointer));

  void _releasePointer(int pointer) =>
      setState(() => _childClaimedPointers.remove(pointer));

  bool _isChildClaimed(int pointer) => _childClaimedPointers.contains(pointer);

  void _onPointerDown(PointerDownEvent event) {
    _activePointers[event.pointer] = event.localPosition;
    if (_activePointers.length == 1 && !_isChildClaimed(event.pointer)) {
      _panStartViewport = event.localPosition;
      _matrixAtPanStart = Matrix4.copy(widget.controller.value);
    } else if (_activePointers.length == 2 &&
        _childClaimedPointers.isEmpty) {
      _beginPinch();
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    _activePointers[event.pointer] = event.localPosition;
    if (_childClaimedPointers.isNotEmpty) return;

    if (_activePointers.length >= 2) {
      _updatePinch();
      return;
    }

    if (_activePointers.length == 1 &&
        _panStartViewport != null &&
        _matrixAtPanStart != null) {
      final delta = event.localPosition - _panStartViewport!;
      widget.controller.value = Matrix4.copy(_matrixAtPanStart!)
        ..translateByDouble(delta.dx, delta.dy, 0, 1);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    final childClaimed = _childClaimedPointers.contains(event.pointer);
    final wasTap =
        _activePointers.length == 1 &&
        _panStartViewport != null &&
        (event.localPosition - _panStartViewport!).distance < 14 &&
        !childClaimed;

    _activePointers.remove(event.pointer);
    _childClaimedPointers.remove(event.pointer);
    if (_activePointers.isEmpty) {
      if (wasTap) {
        widget.onBackgroundTap?.call();
      }
      _panStartViewport = null;
      _matrixAtPanStart = null;
      _pinchStartDistance = null;
      _scaleAtPinchStart = null;
      _focalAtPinchStart = null;
    } else if (_activePointers.length == 1) {
      _panStartViewport = _activePointers.values.first;
      _matrixAtPanStart = Matrix4.copy(widget.controller.value);
      _pinchStartDistance = null;
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);
    _panStartViewport = null;
    _matrixAtPanStart = null;
    _pinchStartDistance = null;
    _scaleAtPinchStart = null;
    _focalAtPinchStart = null;
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _childClaimedPointers.isEmpty) {
      final delta = event.scrollDelta.dy;
      final scaleChange = delta > 0 ? 0.9 : 1.1;
      final focal = event.localPosition;
      _zoomAt(focal, _scale * scaleChange);
    }
  }

  void _beginPinch() {
    final points = _activePointers.values.toList(growable: false);
    if (points.length < 2) return;
    _pinchStartDistance = (points[0] - points[1]).distance;
    _scaleAtPinchStart = _scale;
    _focalAtPinchStart = Offset(
      (points[0].dx + points[1].dx) / 2,
      (points[0].dy + points[1].dy) / 2,
    );
    _panStartViewport = null;
    _matrixAtPanStart = null;
  }

  void _updatePinch() {
    final points = _activePointers.values.toList(growable: false);
    if (points.length < 2 ||
        _pinchStartDistance == null ||
        _scaleAtPinchStart == null ||
        _focalAtPinchStart == null) {
      return;
    }

    final distance = (points[0] - points[1]).distance;
    if (_pinchStartDistance! < 1) return;
    final nextScale = (_scaleAtPinchStart! * (distance / _pinchStartDistance!))
        .clamp(0.35, 2.5);
    _zoomAt(_focalAtPinchStart!, nextScale);
  }

  void _zoomAt(Offset focal, double nextScale) {
    final current = widget.controller.value;
    final currentScale = current.getMaxScaleOnAxis();
    if (currentScale == 0) return;

    final translation = current.getTranslation();
    final scaleDelta = nextScale / currentScale;
    final focalX = focal.dx - translation.x;
    final focalY = focal.dy - translation.y;

    widget.controller.value = Matrix4.identity()
      ..translateByDouble(
        focalX - focalX * scaleDelta + translation.x,
        focalY - focalY * scaleDelta + translation.y,
        0,
        1,
      )
      ..scaleByDouble(scaleDelta, scaleDelta, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    return GraphInteractionScope(
      acquirePointer: _acquirePointer,
      releasePointer: _releasePointer,
      globalToWorld: _globalToWorld,
      scale: _scale,
      child: Listener(
        key: _viewportKey,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        onPointerSignal: _onPointerSignal,
        child: ClipRect(
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, child) {
              return Transform(
                transform: widget.controller.value,
                child: child,
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

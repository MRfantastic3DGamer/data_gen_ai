import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/port_type.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_interaction_scope.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_layout.dart';
import 'package:flutter/material.dart';

class GraphPortWidget extends StatefulWidget {
  const GraphPortWidget({
    super.key,
    required this.port,
    required this.isActive,
    required this.isPendingSource,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final PortDefinition port;
  final bool isActive;
  final bool isPendingSource;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final void Function(Offset worldPosition) onDragUpdate;
  final void Function(Offset worldPosition) onDragEnd;

  @override
  State<GraphPortWidget> createState() => _GraphPortWidgetState();
}

class _GraphPortWidgetState extends State<GraphPortWidget> {
  Offset? _downGlobal;
  var _dragging = false;

  static const double _tapSlop = 14;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInput = widget.port.direction == PortDirection.input;
    final rowHeight = GraphLayoutMetrics.portRowHeight(context);
    final highlight = widget.isActive || widget.isPendingSource;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: Material(
        color: highlight
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : Colors.transparent,
        child: SizedBox(
          height: rowHeight,
          child: Row(
            children: <Widget>[
              if (isInput) _buildPortDot(colorScheme, highlight),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isInput ? 4 : 12,
                    right: isInput ? 12 : 4,
                  ),
                  child: Row(
                    mainAxisAlignment: isInput
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          widget.port.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: highlight ? FontWeight.w600 : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.port.type.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isInput) _buildPortDot(colorScheme, highlight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortDot(ColorScheme colorScheme, bool highlight) {
    final color = _portColor(colorScheme, widget.port.type);
    return SizedBox(
      width: GraphLayoutMetrics.portHitSize,
      height: GraphLayoutMetrics.portHitSize,
      child: Center(
        child: Container(
          width: GraphLayoutMetrics.portDotSize,
          height: GraphLayoutMetrics.portDotSize,
          decoration: BoxDecoration(
            color: highlight ? color : color.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: highlight
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.8),
              width: highlight ? 2 : 1,
            ),
            boxShadow: highlight
                ? <BoxShadow>[
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  void _onPointerDown(PointerDownEvent event) {
    GraphInteractionScope.of(context).acquirePointer(event.pointer);
    _downGlobal = event.position;
    _dragging = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_downGlobal == null) return;
    if (!_dragging &&
        (event.position - _downGlobal!).distance > _tapSlop) {
      _dragging = true;
      widget.onDragStart();
    }
    if (_dragging) {
      widget.onDragUpdate(
        GraphInteractionScope.of(context).globalToWorld(event.position),
      );
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    GraphInteractionScope.of(context).releasePointer(event.pointer);
    if (_downGlobal == null) return;

    if (!_dragging) {
      widget.onTap();
    } else {
      widget.onDragEnd(
        GraphInteractionScope.of(context).globalToWorld(event.position),
      );
    }

    _downGlobal = null;
    _dragging = false;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    GraphInteractionScope.of(context).releasePointer(event.pointer);
    _downGlobal = null;
    _dragging = false;
  }

  Color _portColor(ColorScheme colorScheme, PortType type) {
    return switch (type) {
      PortType.graphQueryRef => const Color(0xFF8B6BB5),
      PortType.belief => const Color(0xFFB57A4A),
      PortType.beliefSelection => const Color(0xFFC48A5A),
      PortType.actionable => const Color(0xFF4A8AB5),
      PortType.graphActuatorRef => const Color(0xFF5A9AC5),
      PortType.characterProfileGraphData => const Color(0xFF597AB8),
      _ => colorScheme.primary,
    };
  }
}

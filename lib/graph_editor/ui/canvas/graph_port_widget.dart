import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/port_type.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_layout.dart';
import 'package:flutter/material.dart';

class GraphPortWidget extends StatelessWidget {
  const GraphPortWidget({
    super.key,
    required this.port,
    required this.isActive,
    required this.onTapDown,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final PortDefinition port;
  final bool isActive;
  final VoidCallback onTapDown;
  final VoidCallback onPanStart;
  final void Function(DragUpdateDetails details) onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInput = port.direction == PortDirection.input;

    return SizedBox(
      height: GraphLayoutMetrics.portRowHeight,
      child: Row(
        children: <Widget>[
          if (isInput)
            _PortDot(
              color: _portColor(colorScheme, port.type),
              isActive: isActive,
              onTapDown: onTapDown,
              onPanStart: onPanStart,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: isInput ? 8 : 12,
                right: isInput ? 12 : 8,
              ),
              child: Row(
                mainAxisAlignment: isInput
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      port.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    port.type.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isInput)
            _PortDot(
              color: _portColor(colorScheme, port.type),
              isActive: isActive,
              onTapDown: onTapDown,
              onPanStart: onPanStart,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
            ),
        ],
      ),
    );
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

class _PortDot extends StatelessWidget {
  const _PortDot({
    required this.color,
    required this.isActive,
    required this.onTapDown,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final Color color;
  final bool isActive;
  final VoidCallback onTapDown;
  final VoidCallback onPanStart;
  final void Function(DragUpdateDetails details) onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onPanStart: (_) => onPanStart(),
      onPanUpdate: onPanUpdate,
      onPanEnd: (_) => onPanEnd(),
      child: Container(
        width: GraphLayoutMetrics.portDotSize,
        height: GraphLayoutMetrics.portDotSize,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.8),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? <BoxShadow>[
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

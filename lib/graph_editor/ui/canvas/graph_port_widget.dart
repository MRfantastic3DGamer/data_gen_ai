import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/port_type.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_layout.dart';
import 'package:flutter/material.dart';

class GraphPortWidget extends StatelessWidget {
  const GraphPortWidget({
    super.key,
    required this.port,
    required this.isActive,
    required this.isPendingSource,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final PortDefinition port;
  final bool isActive;
  final bool isPendingSource;
  final VoidCallback onTap;
  final VoidCallback onPanStart;
  final void Function(DragUpdateDetails details) onPanUpdate;
  final void Function(DragEndDetails details) onPanEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInput = port.direction == PortDirection.input;
    final rowHeight = GraphLayoutMetrics.portRowHeight(context);
    final highlight = isActive || isPendingSource;

    return Material(
      color: highlight
          ? colorScheme.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: rowHeight,
          child: Row(
            children: <Widget>[
              if (isInput) _buildPortHandle(context, colorScheme, highlight),
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
                          port.name,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: highlight ? FontWeight.w600 : null,
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
              if (!isInput) _buildPortHandle(context, colorScheme, highlight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortHandle(
    BuildContext context,
    ColorScheme colorScheme,
    bool highlight,
  ) {
    final color = _portColor(colorScheme, port.type);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onPanStart: (_) => onPanStart(),
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: SizedBox(
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

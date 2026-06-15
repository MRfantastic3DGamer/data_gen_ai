import 'package:data_gen_ai/graph_editor/models/graph_node_data.dart';
import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/port_type.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/vyuh/graph_node_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

/// Inner content for character design nodes. [NodeContainer] wraps this with
/// drag handling and port overlays — keep this widget free of gesture detectors.
class CharacterDesignNodeWidget extends StatelessWidget {
  const CharacterDesignNodeWidget({super.key, required this.node});

  final Node<GraphNodeData> node;

  @override
  Widget build(BuildContext context) {
    final definition = node.data.definition;
    final accent = definition?.accentColor ?? Theme.of(context).colorScheme.primary;
    final isBlock = definition?.isBlockNode ?? false;
    final isContext = definition?.isContextNode ?? false;
    final dataPorts = definition?.resolvePorts(node.data.options) ?? const [];

    return Observer(
      builder: (_) {
        final size = node.size.value;
        return SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _NodeHeader(
                title: node.data.displayName,
                accent: accent,
                isBlock: isBlock,
                isContext: isContext,
              ),
              if (dataPorts.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GraphNodeLayout.bodyPadding,
                      vertical: GraphNodeLayout.bodyPadding,
                    ),
                    child: Column(
                      children: List<Widget>.generate(dataPorts.length, (index) {
                        final port = dataPorts[index];
                        return SizedBox(
                          height: GraphNodeLayout.rowHeight,
                          child: _PortRow(port: port),
                        );
                      }),
                    ),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

class _NodeHeader extends StatelessWidget {
  const _NodeHeader({
    required this.title,
    required this.accent,
    required this.isBlock,
    required this.isContext,
  });

  final String title;
  final Color accent;
  final bool isBlock;
  final bool isContext;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: GraphNodeLayout.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.drag_indicator, size: 18, color: accent.withValues(alpha: 0.8)),
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isContext) _Badge(label: 'Context', color: accent),
          if (isBlock) _Badge(label: 'Block', color: accent),
        ],
      ),
    );
  }
}

class _PortRow extends StatelessWidget {
  const _PortRow({required this.port});

  final PortDefinition port;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            port.name,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          port.type.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 14),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

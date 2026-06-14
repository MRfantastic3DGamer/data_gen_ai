import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NodePalettePanel extends StatelessWidget {
  const NodePalettePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final nodes = NodeRegistry.paletteNodes();
    final grouped = <String, List<NodeTypeDefinition>>{};
    for (final node in nodes) {
      grouped.putIfAbsent(node.category, () => <NodeTypeDefinition>[]).add(node);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Nodes',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  ...entry.value.map(
                    (definition) => _PaletteTile(definition: definition),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.definition});

  final NodeTypeDefinition definition;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final state = context.read<GraphEditorCubit>().state;
          final offset = state.viewportOffset;
          final x = 120 + (state.document.nodes.length * 24);
          final y = 120 + (state.document.nodes.length * 24);
          context.read<GraphEditorCubit>().addNode(
            definition.typeId,
            GraphPosition(x: x - offset.dx, y: y - offset.dy),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: definition.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      definition.displayName,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (definition.description != null)
                      Text(
                        definition.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.add_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:data_gen_ai/core/theme/app_spacing.dart';
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
    final blocks = NodeRegistry.all.where((d) => d.isBlockNode).toList();

    final groupedNodes = <String, List<NodeTypeDefinition>>{};
    for (final node in nodes) {
      groupedNodes.putIfAbsent(node.category, () => <NodeTypeDefinition>[]).add(node);
    }

    final groupedBlocks = <String, List<NodeTypeDefinition>>{};
    for (final block in blocks) {
      final parentName =
          NodeRegistry.byTypeId(block.parentContextTypeId!)?.displayName ??
          'Context';
      groupedBlocks.putIfAbsent(parentName, () => <NodeTypeDefinition>[]).add(block);
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
            children: <Widget>[
              ...groupedNodes.entries.map(
                (entry) => _CategorySection(
                  title: entry.key,
                  definitions: entry.value,
                ),
              ),
              if (blocks.isNotEmpty) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    'Blocks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Place block nodes on the canvas, then connect their top Block port to a context node\'s bottom Blocks port.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ...groupedBlocks.entries.map(
                  (entry) => _CategorySection(
                    title: entry.key,
                    definitions: entry.value,
                    isBlock: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.definitions,
    this.isBlock = false,
  });

  final String title;
  final List<NodeTypeDefinition> definitions;
  final bool isBlock;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...definitions.map(
          (definition) => _PaletteTile(definition: definition, isBlock: isBlock),
        ),
      ],
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({required this.definition, this.isBlock = false});

  final NodeTypeDefinition definition;
  final bool isBlock;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final state = context.read<GraphEditorCubit>().state;
          final count = state.document.nodes.length;
          final x = 120.0 + (count * 28);
          final y = 120.0 + (count * 28) + (isBlock ? 80 : 0);
          context.read<GraphEditorCubit>().addNode(
            definition.typeId,
            Offset(x, y),
          );
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
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

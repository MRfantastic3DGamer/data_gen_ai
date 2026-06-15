import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NodePalettePanel extends StatefulWidget {
  const NodePalettePanel({
    super.key,
    this.scrollController,
    this.compact = false,
    this.onNodeAdded,
  });

  final ScrollController? scrollController;
  final bool compact;
  final void Function(String displayName)? onNodeAdded;

  @override
  State<NodePalettePanel> createState() => _NodePalettePanelState();
}

class _NodePalettePanelState extends State<NodePalettePanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = NodeRegistry.paletteNodes();
    final blocks = NodeRegistry.all.where((d) => d.isBlockNode).toList();

    final groupedNodes = _groupByCategory(nodes);
    final groupedBlocks = _groupBlocksByParent(blocks);

    if (widget.compact) {
      return Column(
        children: <Widget>[
          TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: 'Nodes'),
              Tab(text: 'Blocks'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _PaletteList(
                  scrollController: widget.scrollController,
                  sections: groupedNodes,
                  emptyMessage: 'No nodes available.',
                  onNodeAdded: widget.onNodeAdded,
                ),
                _PaletteList(
                  scrollController: widget.scrollController,
                  sections: groupedBlocks,
                  emptyMessage: 'No blocks available.',
                  isBlock: true,
                  onNodeAdded: widget.onNodeAdded,
                  header: Text(
                    'Connect a block\'s top Block port to a context node\'s bottom Blocks port.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (!widget.compact)
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
          child: _PaletteList(
            scrollController: widget.scrollController,
            sections: groupedNodes,
            emptyMessage: 'No nodes available.',
            onNodeAdded: widget.onNodeAdded,
            footer: blocks.isEmpty
                ? null
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          'Blocks',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
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
                          onNodeAdded: widget.onNodeAdded,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Map<String, List<NodeTypeDefinition>> _groupByCategory(
    List<NodeTypeDefinition> definitions,
  ) {
    final grouped = <String, List<NodeTypeDefinition>>{};
    for (final definition in definitions) {
      grouped
          .putIfAbsent(definition.category, () => <NodeTypeDefinition>[])
          .add(definition);
    }
    return grouped;
  }

  Map<String, List<NodeTypeDefinition>> _groupBlocksByParent(
    List<NodeTypeDefinition> blocks,
  ) {
    final grouped = <String, List<NodeTypeDefinition>>{};
    for (final block in blocks) {
      final parentName =
          NodeRegistry.byTypeId(block.parentContextTypeId!)?.displayName ??
          'Context';
      grouped.putIfAbsent(parentName, () => <NodeTypeDefinition>[]).add(block);
    }
    return grouped;
  }
}

class _PaletteList extends StatelessWidget {
  const _PaletteList({
    required this.sections,
    required this.emptyMessage,
    this.scrollController,
    this.isBlock = false,
    this.onNodeAdded,
    this.header,
    this.footer,
  });

  final Map<String, List<NodeTypeDefinition>> sections;
  final String emptyMessage;
  final ScrollController? scrollController;
  final bool isBlock;
  final void Function(String displayName)? onNodeAdded;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: <Widget>[
        if (header != null) ...<Widget>[header!, const SizedBox(height: 12)],
        ...sections.entries.map(
          (entry) => _CategorySection(
            title: entry.key,
            definitions: entry.value,
            isBlock: isBlock,
            onNodeAdded: onNodeAdded,
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.definitions,
    this.isBlock = false,
    this.onNodeAdded,
  });

  final String title;
  final List<NodeTypeDefinition> definitions;
  final bool isBlock;
  final void Function(String displayName)? onNodeAdded;

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
          (definition) => _PaletteTile(
            definition: definition,
            isBlock: isBlock,
            onNodeAdded: onNodeAdded,
          ),
        ),
      ],
    );
  }
}

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({
    required this.definition,
    this.isBlock = false,
    this.onNodeAdded,
  });

  final NodeTypeDefinition definition;
  final bool isBlock;
  final void Function(String displayName)? onNodeAdded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.read<GraphEditorCubit>().addNodeAtViewportCenter(
            definition.typeId,
            isBlock: isBlock,
          );
          onNodeAdded?.call(definition.displayName);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      definition.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (definition.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          definition.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

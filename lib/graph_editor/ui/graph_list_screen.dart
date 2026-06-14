import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/graph_editor/services/graph_file_service.dart';
import 'package:data_gen_ai/widgets/common/app_snackbar.dart';
import 'package:data_gen_ai/widgets/common/empty_state.dart';
import 'package:data_gen_ai/widgets/common/loading_indicator.dart';
import 'package:data_gen_ai/widgets/common/nav_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GraphListScreen extends StatefulWidget {
  const GraphListScreen({super.key});

  @override
  State<GraphListScreen> createState() => _GraphListScreenState();
}

class _GraphListScreenState extends State<GraphListScreen> {
  late Future<List<GraphFileInfo>> _graphsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _graphsFuture = context.read<GraphFileService>().listGraphs();
  }

  Future<void> _createGraph() async {
    final controller = TextEditingController(text: 'NewGraph');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Character Design Graph'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Graph name',
            hintText: 'Aggressive_Brawler_Pattern',
          ),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (!mounted || name == null || name.isEmpty) return;

    try {
      final key = await context.read<GraphFileService>().createGraph(name);
      if (!mounted) return;
      setState(_reload);
      context.push('/graphs/edit', extra: key);
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(context, 'Failed to create graph: $error');
    }
  }

  Future<void> _deleteGraph(GraphFileInfo info) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete graph?'),
        content: Text('Delete "${info.graphName}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await context.read<GraphFileService>().deleteGraph(info.key);
    if (!mounted) return;
    setState(_reload);
    AppSnackBar.show(context, 'Deleted ${info.graphName}');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Design Graphs'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => setState(_reload),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createGraph,
        icon: const Icon(Icons.add),
        label: const Text('New graph'),
      ),
      body: FutureBuilder<List<GraphFileInfo>>(
        future: _graphsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Could not load graphs',
              subtitle: snapshot.error.toString(),
            );
          }

          final graphs = snapshot.data ?? const <GraphFileInfo>[];
          if (graphs.isEmpty) {
            return EmptyState(
              icon: Icons.hub_outlined,
              title: 'No graphs yet',
              subtitle:
                  'Create a character design graph to author beliefs, actions, and actuators.',
              actionLabel: 'Create graph',
              onAction: _createGraph,
            );
          }

          return ListView(
            padding: AppSpacing.pagePadding(context),
            children: <Widget>[
              NavCard(
                title: 'Graph authoring',
                subtitle:
                    'Create nodes, wire typed ports, and export JSON for Unity import',
                icon: Icons.account_tree_outlined,
                iconColor: colorScheme.primary,
                delayMs: 0,
                onTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              ...graphs.map(
                (graph) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.hub_outlined,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(graph.graphName),
                    subtitle: Text(graph.key),
                    trailing: IconButton(
                      tooltip: 'Delete',
                      onPressed: () => _deleteGraph(graph),
                      icon: const Icon(Icons.delete_outline),
                    ),
                    onTap: () => context.push('/graphs/edit', extra: graph.key),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

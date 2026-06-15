import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphMobileToolbar extends StatelessWidget {
  const GraphMobileToolbar({
    super.key,
    required this.onAddNode,
    required this.onEditSelection,
    required this.onFitView,
    required this.onDeleteSelected,
  });

  final VoidCallback onAddNode;
  final VoidCallback onEditSelection;
  final VoidCallback onFitView;
  final VoidCallback onDeleteSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphEditorCubit, GraphEditorState>(
      builder: (context, state) {
        final hasSelection = state.selectedNodeId != null;
        final selectedName =
            state.selectedNode?.type.split('.').last ?? 'Node';

        return Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (hasSelection)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Chip(
                        avatar: Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text('Selected: $selectedName'),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onAddNode,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Edit selected node',
                        onPressed: hasSelection ? onEditSelection : null,
                        icon: const Icon(Icons.tune_rounded),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Fit graph to view',
                        onPressed: onFitView,
                        icon: const Icon(Icons.fit_screen_outlined),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Delete selected node',
                        onPressed: hasSelection ? onDeleteSelected : null,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

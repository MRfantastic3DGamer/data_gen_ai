import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphMobileToolbar extends StatelessWidget {
  const GraphMobileToolbar({
    super.key,
    required this.onAddNode,
    required this.onEditSelection,
  });

  final VoidCallback onAddNode;
  final VoidCallback onEditSelection;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphEditorCubit, GraphEditorState>(
      builder: (context, state) {
        final hasSelection = state.selectedNodeId != null;
        return Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: onAddNode,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add node'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: hasSelection ? onEditSelection : null,
                      icon: const Icon(Icons.tune_rounded),
                      label: const Text('Edit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

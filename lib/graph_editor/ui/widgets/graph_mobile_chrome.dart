import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphConnectionBanner extends StatelessWidget {
  const GraphConnectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphEditorCubit, GraphEditorState>(
      buildWhen: (previous, current) =>
          previous.pendingConnection != current.pendingConnection,
      builder: (context, state) {
        final pending = state.pendingConnection;
        if (pending == null) return const SizedBox.shrink();

        final colorScheme = Theme.of(context).colorScheme;
        return Material(
          elevation: 4,
          color: colorScheme.primaryContainer,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.cable_rounded,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap a compatible port to connect from "${pending.portName}"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<GraphEditorCubit>().cancelConnection(),
                    child: const Text('Cancel'),
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
        final hasSelection =
            state.selectedNodeId != null || state.selectedBlockId != null;
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

class GraphMobileHelpBanner extends StatelessWidget {
  const GraphMobileHelpBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphEditorCubit, GraphEditorState>(
      buildWhen: (previous, current) =>
          previous.pendingConnection != current.pendingConnection &&
          previous.selectedNodeId != current.selectedNodeId,
      builder: (context, state) {
        if (state.pendingConnection != null) {
          return const SizedBox.shrink();
        }
        if (state.selectedNodeId != null || state.selectedBlockId != null) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Tap a node header or body to select it, then tap Edit below. '
                'To connect ports: tap a port, then tap a compatible port on another node or block. '
                'Drag the header to move a node. Drag empty space to pan, pinch to zoom.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

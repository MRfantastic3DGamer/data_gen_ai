import 'package:data_gen_ai/graph_editor/services/graph_file_service.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_canvas.dart';
import 'package:data_gen_ai/graph_editor/ui/panels/node_options_panel.dart';
import 'package:data_gen_ai/graph_editor/ui/panels/node_palette_panel.dart';
import 'package:data_gen_ai/widgets/common/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphEditorScreen extends StatefulWidget {
  const GraphEditorScreen({super.key, required this.fileKey});

  final String fileKey;

  @override
  State<GraphEditorScreen> createState() => _GraphEditorScreenState();
}

class _GraphEditorScreenState extends State<GraphEditorScreen> {
  late final GraphEditorCubit _cubit;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _cubit = GraphEditorCubit(context.read<GraphFileService>());
    _nameController = TextEditingController();
    _loadGraph();
  }

  Future<void> _loadGraph() async {
    final service = context.read<GraphFileService>();
    final document = await service.loadGraph(widget.fileKey);
    _cubit.load(document, widget.fileKey);
    _nameController.text = document.graphName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<GraphEditorCubit, GraphEditorState>(
        listenWhen: (previous, current) =>
            previous.connectionError != current.connectionError &&
            current.connectionError != null,
        listener: (context, state) {
          if (state.connectionError != null) {
            AppSnackBar.show(context, state.connectionError!);
          }
          if (_nameController.text != state.document.graphName) {
            _nameController.text = state.document.graphName;
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Graph name',
                ),
                style: Theme.of(context).textTheme.titleLarge,
                onSubmitted: context.read<GraphEditorCubit>().setGraphName,
              ),
              actions: <Widget>[
                if (state.isDirty)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Chip(label: Text('Unsaved')),
                  ),
                IconButton(
                  tooltip: 'Delete selected',
                  onPressed:
                      (state.selectedNodeId != null ||
                          state.selectedBlockId != null)
                      ? () => context.read<GraphEditorCubit>().removeSelected()
                      : null,
                  icon: const Icon(Icons.delete_outline),
                ),
                FilledButton.icon(
                  onPressed: state.isSaving
                      ? null
                      : () => context.read<GraphEditorCubit>().save(),
                  icon: state.isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Row(
              children: <Widget>[
                const SizedBox(
                  width: 260,
                  child: NodePalettePanel(),
                ),
                const VerticalDivider(width: 1),
                const Expanded(child: GraphCanvas()),
                const VerticalDivider(width: 1),
                const SizedBox(
                  width: 320,
                  child: NodeOptionsPanel(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

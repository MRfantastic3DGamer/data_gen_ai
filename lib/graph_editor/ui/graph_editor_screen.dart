import 'package:data_gen_ai/graph_editor/services/graph_file_service.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_canvas.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_layout.dart';
import 'package:data_gen_ai/graph_editor/ui/panels/node_options_panel.dart';
import 'package:data_gen_ai/graph_editor/ui/panels/node_palette_panel.dart';
import 'package:data_gen_ai/graph_editor/ui/widgets/graph_mobile_chrome.dart';
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

  void _showPaletteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Add node',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Expanded(child: NodePalettePanel()),
          ],
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    final state = _cubit.state;
    if (state.selectedNodeId == null && state.selectedBlockId == null) {
      AppSnackBar.showError(context, 'Tap a node on the canvas first.');
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (context, scrollController) => const SizedBox(
          height: 500,
          child: NodeOptionsPanel(),
        ),
      ),
    );
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
            AppSnackBar.showError(context, state.connectionError!);
          }
          if (_nameController.text != state.document.graphName) {
            _nameController.text = state.document.graphName;
          }
        },
        builder: (context, state) {
          final isMobile = GraphLayoutMetrics.isMobile(context);

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
                  label: Text(isMobile ? '' : 'Save'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: isMobile ? _buildMobileBody(context) : _buildDesktopBody(context),
          );
        },
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Column(
      children: <Widget>[
        const GraphConnectionBanner(),
        Expanded(
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 260,
                child: NodePalettePanel(),
              ),
              const VerticalDivider(width: 1),
              const Expanded(child: GraphCanvas(showHelpBanner: false)),
              const VerticalDivider(width: 1),
              const SizedBox(
                width: 320,
                child: NodeOptionsPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return Column(
      children: <Widget>[
        const GraphConnectionBanner(),
        const Expanded(
          child: GraphCanvas(),
        ),
        GraphMobileToolbar(
          onAddNode: () => _showPaletteSheet(context),
          onEditSelection: () => _showOptionsSheet(context),
        ),
      ],
    );
  }
}

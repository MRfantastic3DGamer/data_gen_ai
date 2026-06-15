import 'package:data_gen_ai/graph_editor/services/graph_file_service.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:data_gen_ai/graph_editor/ui/graph_editor_layout.dart';
import 'package:data_gen_ai/graph_editor/ui/panels/node_options_panel.dart';
import 'package:data_gen_ai/graph_editor/ui/panels/node_palette_panel.dart';
import 'package:data_gen_ai/graph_editor/ui/sheets/graph_options_sheet.dart';
import 'package:data_gen_ai/graph_editor/ui/sheets/graph_palette_sheet.dart';
import 'package:data_gen_ai/graph_editor/ui/vyuh_graph_canvas.dart';
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

  void _showPaletteSheet() {
    showGraphPaletteSheet(context, cubit: _cubit);
  }

  void _showOptionsSheet() {
    if (_cubit.state.selectedNodeId == null) {
      AppSnackBar.showError(context, 'Tap a node on the canvas first.');
      return;
    }
    showGraphOptionsSheet(context, cubit: _cubit);
  }

  Future<void> _promptRename() async {
    final controller = TextEditingController(text: _cubit.state.document.graphName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename graph'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Graph name'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty) {
      _cubit.setGraphName(name.trim());
      _nameController.text = name.trim();
    }
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
        },
        builder: (context, state) {
          final compact = isCompactGraphEditor(context);

          return Scaffold(
            appBar: compact
                ? _buildCompactAppBar(context, state)
                : _buildWideAppBar(context, state),
            body: compact ? _buildCompactBody() : _buildWideBody(),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildCompactAppBar(
    BuildContext context,
    GraphEditorState state,
  ) {
    return AppBar(
      title: Text(
        state.document.graphName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
        if (state.isDirty)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              Icons.circle,
              size: 10,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        PopupMenuButton<_CompactMenuAction>(
          onSelected: (action) => _handleCompactMenu(action),
          itemBuilder: (context) => <PopupMenuEntry<_CompactMenuAction>>[
            PopupMenuItem(
              value: _CompactMenuAction.save,
              enabled: !state.isSaving,
              child: ListTile(
                leading: const Icon(Icons.save_outlined),
                title: Text(state.isSaving ? 'Saving…' : 'Save graph'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: _CompactMenuAction.rename,
              child: ListTile(
                leading: Icon(Icons.drive_file_rename_outline),
                title: Text('Rename graph'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: _CompactMenuAction.fit,
              child: ListTile(
                leading: Icon(Icons.fit_screen_outlined),
                title: Text('Fit to view'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _CompactMenuAction.delete,
              enabled: state.selectedNodeId != null,
              child: const ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Delete selected node'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _buildWideAppBar(
    BuildContext context,
    GraphEditorState state,
  ) {
    return AppBar(
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
          tooltip: 'Fit to view',
          onPressed: _cubit.fitGraphToView,
          icon: const Icon(Icons.fit_screen_outlined),
        ),
        IconButton(
          tooltip: 'Delete selected',
          onPressed: state.selectedNodeId != null ? _cubit.removeSelected : null,
          icon: const Icon(Icons.delete_outline),
        ),
        FilledButton.icon(
          onPressed: state.isSaving ? null : _cubit.save,
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
    );
  }

  void _handleCompactMenu(_CompactMenuAction action) {
    switch (action) {
      case _CompactMenuAction.save:
        _cubit.save();
      case _CompactMenuAction.rename:
        _promptRename();
      case _CompactMenuAction.fit:
        _cubit.fitGraphToView();
      case _CompactMenuAction.delete:
        _cubit.removeSelected();
    }
  }

  Widget _buildWideBody() {
    return Row(
      children: <Widget>[
        const SizedBox(
          width: 260,
          child: NodePalettePanel(),
        ),
        const VerticalDivider(width: 1),
        const Expanded(child: VyuhGraphCanvas()),
        const VerticalDivider(width: 1),
        const SizedBox(
          width: 320,
          child: NodeOptionsPanel(),
        ),
      ],
    );
  }

  Widget _buildCompactBody() {
    return Column(
      children: <Widget>[
        const Expanded(child: VyuhGraphCanvas()),
        GraphMobileToolbar(
          onAddNode: _showPaletteSheet,
          onEditSelection: _showOptionsSheet,
          onFitView: _cubit.fitGraphToView,
          onDeleteSelected: _cubit.removeSelected,
        ),
      ],
    );
  }
}

enum _CompactMenuAction { save, rename, fit, delete }

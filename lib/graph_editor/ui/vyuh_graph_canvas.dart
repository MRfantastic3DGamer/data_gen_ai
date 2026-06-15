import 'package:data_gen_ai/graph_editor/models/graph_node_data.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/ui/graph_editor_layout.dart';
import 'package:data_gen_ai/graph_editor/vyuh/character_design_node_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as vyuh;

class VyuhGraphCanvas extends StatefulWidget {
  const VyuhGraphCanvas({super.key});

  @override
  State<VyuhGraphCanvas> createState() => _VyuhGraphCanvasState();
}

class _VyuhGraphCanvasState extends State<VyuhGraphCanvas> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (isCompactGraphEditor(context)) {
      context.read<GraphEditorCubit>().controller.minimap?.setVisible(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GraphEditorCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return vyuh.NodeFlowEditor<GraphNodeData, dynamic>(
      controller: cubit.controller,
      theme: isDark ? vyuh.NodeFlowTheme.dark : vyuh.NodeFlowTheme.light,
      events: cubit.buildEvents(),
      nodeBuilder: (context, node) => CharacterDesignNodeWidget(node: node),
    );
  }
}

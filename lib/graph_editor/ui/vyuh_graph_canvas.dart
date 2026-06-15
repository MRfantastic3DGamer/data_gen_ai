import 'package:data_gen_ai/graph_editor/models/graph_node_data.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/vyuh/character_design_node_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

class VyuhGraphCanvas extends StatelessWidget {
  const VyuhGraphCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GraphEditorCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NodeFlowEditor<GraphNodeData, dynamic>(
      controller: cubit.controller,
      theme: isDark ? NodeFlowTheme.dark : NodeFlowTheme.light,
      events: cubit.buildEvents(),
      nodeBuilder: (context, node) => CharacterDesignNodeWidget(node: node),
    );
  }
}

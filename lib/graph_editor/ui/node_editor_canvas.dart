import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:node_editor/node_editor.dart';

class NodeEditorCanvas extends StatefulWidget {
  const NodeEditorCanvas({super.key});

  @override
  State<NodeEditorCanvas> createState() => _NodeEditorCanvasState();
}

class _NodeEditorCanvasState extends State<NodeEditorCanvas> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GraphEditorCubit>().attachFocusNode(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GraphEditorCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NodeEditor(
      focusNode: _focusNode,
      controller: cubit.controller,
      infiniteCanvasSize: 8000,
      background: GridBackground(
        lineColor: isDark
            ? const Color(0xFF2A2D34)
            : const Color(0xFFE3E6EC),
        backgroundColor: isDark
            ? const Color(0xFF14151A)
            : const Color(0xFFF3F5F8),
      ),
    );
  }
}

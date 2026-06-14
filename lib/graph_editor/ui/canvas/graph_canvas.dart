import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_edge_painter.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_layout.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_node_widget.dart';
import 'package:data_gen_ai/graph_editor/ui/widgets/graph_mobile_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphCanvas extends StatefulWidget {
  const GraphCanvas({super.key, this.showHelpBanner = true});

  final bool showHelpBanner;

  @override
  State<GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<GraphCanvas> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Offset _globalToWorld(Offset global) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return global;
    final local = renderBox.globalToLocal(global);
    final matrix = Matrix4.inverted(_transformController.value);
    return MatrixUtils.transformPoint(matrix, local);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphEditorCubit, GraphEditorState>(
      builder: (context, state) {
        final colorScheme = Theme.of(context).colorScheme;
        final portRowHeight = GraphLayoutMetrics.portRowHeight(context);

        return Stack(
          children: <Widget>[
            InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.35,
              maxScale: 2.5,
              boundaryMargin: const EdgeInsets.all(1200),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  final cubit = context.read<GraphEditorCubit>();
                  if (cubit.state.pendingConnection != null) {
                    cubit.cancelConnection();
                  } else {
                    cubit.clearSelection();
                  }
                },
                child: SizedBox(
                  width: 4000,
                  height: 3000,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      CustomPaint(
                        size: const Size(4000, 3000),
                        painter: GraphEdgePainter(
                          document: state.document,
                          selectedEdge: null,
                          pendingConnection: state.pendingConnection,
                          colorScheme: colorScheme,
                          portRowHeight: portRowHeight,
                        ),
                      ),
                      ...state.document.nodes.map((node) {
                        final contextEntry = state.document.contextForNode(
                          node.id,
                        );
                        return GraphNodeWidget(
                          node: node,
                          isSelected: state.selectedNodeId == node.id,
                          blocks: contextEntry?.blocks ?? const [],
                          selectedBlockId: state.selectedBlockId,
                          pendingNodeId: state.pendingConnection?.nodeId,
                          pendingPortName: state.pendingConnection?.portName,
                          onSelect: () => context
                              .read<GraphEditorCubit>()
                              .selectNode(node.id),
                          onSelectBlock: (blockId) => context
                              .read<GraphEditorCubit>()
                              .selectBlock(node.id, blockId),
                          onAddBlock: (blockTypeId) => context
                              .read<GraphEditorCubit>()
                              .addBlock(node.id, blockTypeId),
                          worldToLocal: _globalToWorld,
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.showHelpBanner &&
                GraphLayoutMetrics.isMobile(context))
              const GraphMobileHelpBanner(),
          ],
        );
      },
    );
  }
}

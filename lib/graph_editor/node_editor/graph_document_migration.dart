import 'package:data_gen_ai/graph_editor/models/graph_block.dart';
import 'package:data_gen_ai/graph_editor/models/graph_context.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';

abstract final class GraphDocumentMigration {
  /// Converts nested `contexts` blocks into standalone nodes + Blocks→Block edges.
  static GraphDocument migrateLegacyContexts(GraphDocument document) {
    if (document.contexts.isEmpty) return document;

    final nodes = List<GraphNode>.from(document.nodes);
    final edges = List<GraphEdge>.from(document.edges);
    var blockIndex = 0;

    for (final context in document.contexts) {
      final parent = document.nodeById(context.parentNodeId);
      if (parent == null) continue;

      for (final block in context.blocks) {
        final existing = nodes.any((n) => n.id == block.id);
        if (!existing) {
          nodes.add(_blockAsNode(block, parent, blockIndex));
          blockIndex += 1;
        }

        final hasAttachment = edges.any(
          (e) =>
              e.fromNode == context.parentNodeId &&
              e.fromPort == StructuralPorts.blocks &&
              e.toNode == block.id &&
              e.toPort == StructuralPorts.block,
        );
        if (!hasAttachment) {
          edges.add(
            GraphEdge(
              fromNode: context.parentNodeId,
              fromPort: StructuralPorts.blocks,
              toNode: block.id,
              toPort: StructuralPorts.block,
            ),
          );
        }
      }
    }

    return document.copyWith(nodes: nodes, edges: edges, contexts: const []);
  }

  static GraphNode _blockAsNode(
    GraphBlock block,
    GraphNode parent,
    int index,
  ) {
    return GraphNode(
      id: block.id,
      type: block.type,
      position: GraphPosition(
        x: parent.position.x + (index * 40),
        y: parent.position.y + 180 + (index * 24),
      ),
      options: Map<String, dynamic>.from(block.options),
    );
  }
}

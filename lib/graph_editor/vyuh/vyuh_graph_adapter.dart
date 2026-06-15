import 'package:data_gen_ai/graph_editor/logic/graph_editor_logic.dart';
import 'package:data_gen_ai/graph_editor/models/graph_block.dart';
import 'package:data_gen_ai/graph_editor/models/graph_context.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node_data.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/vyuh/vyuh_port_builder.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' hide GraphPosition;

abstract final class VyuhGraphAdapter {
  static const _uuid = Uuid();
  static const _nodeWidth = 220.0;
  static const _portRowHeight = 28.0;
  static const _headerHeight = 44.0;

  static double estimateNodeHeight(String unityTypeId, Map<String, dynamic> options) {
    final definition = NodeRegistry.byTypeId(unityTypeId);
    if (definition == null) return _headerHeight + 40;

    var rows = definition.resolvePorts(options).length;
    if (definition.isContextNode) rows += 1;
    if (definition.isBlockNode) rows += 1;
    return _headerHeight + (rows * _portRowHeight) + 16;
  }

  static NodeFlowController<GraphNodeData, dynamic> controllerFromDocument(
    GraphDocument document,
  ) {
    final migrated = migrateLegacyContexts(document);
    final nodes = migrated.nodes
        .map((node) => vyuhNodeFromGraphNode(node))
        .toList();
    final connections = migrated.edges
        .map((edge) => connectionFromEdge(edge))
        .toList();

    return NodeFlowController<GraphNodeData, dynamic>(
      nodes: nodes,
      connections: connections,
      config: NodeFlowConfig(
        plugins: <NodeFlowPlugin>[
          MinimapPlugin(visible: true),
        ],
      ),
    );
  }

  static GraphDocument documentFromController(
    NodeFlowController<GraphNodeData, dynamic> controller, {
    required String graphName,
  }) {
    final graph = controller.exportGraph();
    final nodes = graph.nodes.map(graphNodeFromVyuh).toList();
    final edges = graph.connections.map(edgeFromConnection).toList();

    return GraphDocument(
      graphName: graphName,
      nodes: nodes,
      edges: edges,
      contexts: const <GraphContext>[],
    );
  }

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

  static Node<GraphNodeData> vyuhNodeFromGraphNode(GraphNode node) {
    final data = GraphNodeData.fromGraphNode(node);
    return Node<GraphNodeData>(
      id: node.id,
      type: node.type,
      position: Offset(node.position.x, node.position.y),
      data: data,
      size: Size(
        _nodeWidth,
        estimateNodeHeight(node.type, node.options),
      ),
      ports: VyuhPortBuilder.buildPorts(node.type, node.options),
    );
  }

  static GraphNode graphNodeFromVyuh(Node<GraphNodeData> node) {
    return GraphNode(
      id: node.id,
      type: node.data.unityTypeId,
      position: GraphPosition(x: node.position.value.dx, y: node.position.value.dy),
      options: Map<String, dynamic>.from(node.data.options),
    );
  }

  static Connection<dynamic> connectionFromEdge(GraphEdge edge) {
    return Connection<dynamic>(
      id: 'edge-${_uuid.v4().substring(0, 8)}',
      sourceNodeId: edge.fromNode,
      sourcePortId: edge.fromPort,
      targetNodeId: edge.toNode,
      targetPortId: edge.toPort,
    );
  }

  static GraphEdge edgeFromConnection(Connection<dynamic> connection) {
    return GraphEdge(
      fromNode: connection.sourceNodeId,
      fromPort: connection.sourcePortId,
      toNode: connection.targetNodeId,
      toPort: connection.targetPortId,
    );
  }

  static Node<GraphNodeData> createVyuhNode(
    String unityTypeId,
    Offset position,
  ) {
    final graphNode = GraphEditorLogic.createNode(
      unityTypeId,
      GraphPosition(x: position.dx, y: position.dy),
    );
    return vyuhNodeFromGraphNode(graphNode);
  }

  static void refreshNodePorts(Node<GraphNodeData> node) {
    final ports = VyuhPortBuilder.buildPorts(
      node.data.unityTypeId,
      node.data.options,
    );
    final existingIds = node.ports.map((p) => p.id).toSet();
    for (final port in ports) {
      if (existingIds.contains(port.id)) {
        node.updatePort(port.id, port);
      } else {
        node.addPort(port);
      }
    }
    for (final existing in List<Port>.from(node.ports)) {
      if (!ports.any((p) => p.id == existing.id)) {
        node.removePort(existing.id);
      }
    }
    node.setSize(
      Size(
        _nodeWidth,
        estimateNodeHeight(node.data.unityTypeId, node.data.options),
      ),
    );
  }
}

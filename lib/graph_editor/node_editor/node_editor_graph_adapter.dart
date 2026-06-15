import 'dart:ui';

import 'package:data_gen_ai/graph_editor/logic/graph_editor_logic.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/node_editor/character_design_node_factory.dart';
import 'package:data_gen_ai/graph_editor/node_editor/graph_document_migration.dart';
import 'package:flutter/material.dart';
import 'package:node_editor/node_editor.dart';

abstract final class NodeEditorGraphAdapter {
  static GraphDocument migrateLegacyContexts(GraphDocument document) {
    return GraphDocumentMigration.migrateLegacyContexts(document);
  }

  static GraphDocument documentFromController(
    NodeEditorController controller, {
    required String graphName,
    required GraphDocument base,
  }) {
    final nodes = base.nodes.map((node) {
      final runtime = controller.nodes[node.id];
      final position = runtime?.pos;
      if (position == null) return node;
      return node.copyWith(
        position: GraphPosition(x: position.dx, y: position.dy),
      );
    }).toList();

    final edges = controller.connections
        .map(
          (connection) => GraphEdge(
            fromNode: connection.outNode.name,
            fromPort: connection.outPort.name,
            toNode: connection.inNode.name,
            toPort: connection.inPort.name,
          ),
        )
        .toList();

    return base.copyWith(
      graphName: graphName,
      nodes: nodes,
      edges: edges,
      contexts: const [],
    );
  }

  static void clearController(NodeEditorController controller) {
    for (final nodeName in controller.nodes.keys.toList()) {
      controller.nodesManager.removeNode(controller.connectionsManager, nodeName);
    }
    controller.connectionsManager.connections.clear();
    controller.notify();
  }

  static void loadDocument(
    NodeEditorController controller,
    GraphDocument document, {
    required GraphConnectionHandler onConnect,
    VoidCallback? onReady,
  }) {
    final migrated = migrateLegacyContexts(document);
    clearController(controller);

    for (final node in migrated.nodes) {
      controller.addNode(
        CharacterDesignNodeFactory.build(node, onConnect: onConnect),
        NodePosition.custom(
          Offset(node.position.x, node.position.y),
        ),
      );
    }

    _afterPortsReady(() {
      _restoreConnections(controller, migrated.edges);
      onReady?.call();
      controller.notify();
    });
  }

  static void addNode(
    NodeEditorController controller,
    GraphNode node, {
    required GraphConnectionHandler onConnect,
  }) {
    controller.addNode(
      CharacterDesignNodeFactory.build(node, onConnect: onConnect),
      NodePosition.custom(Offset(node.position.x, node.position.y)),
    );
    controller.selectNodeAction(node.id);
    controller.notify();
  }

  static void replaceNode(
    NodeEditorController controller,
    GraphNode node, {
    required GraphConnectionHandler onConnect,
  }) {
    final position = controller.nodes[node.id]?.pos ??
        Offset(node.position.x, node.position.y);
    final preservedEdges = controller.connections
        .where(
          (connection) =>
              connection.inNode.name == node.id ||
              connection.outNode.name == node.id,
        )
        .map(
          (connection) => GraphEdge(
            fromNode: connection.outNode.name,
            fromPort: connection.outPort.name,
            toNode: connection.inNode.name,
            toPort: connection.inPort.name,
          ),
        )
        .toList();

    controller.nodesManager.removeNode(controller.connectionsManager, node.id);
    controller.addNode(
      CharacterDesignNodeFactory.build(node, onConnect: onConnect),
      NodePosition.custom(position),
    );

    _afterPortsReady(() {
      _restoreConnections(controller, preservedEdges);
      controller.selectNodeAction(node.id);
      controller.notify();
    });
  }

  static GraphNode createGraphNode(String typeId, Offset position) {
    return GraphEditorLogic.createNode(
      typeId,
      GraphPosition(x: position.dx, y: position.dy),
    );
  }

  static Offset viewportCenter(NodeEditorController controller) {
    final screen = controller.currentScreenSize ?? const Size(480, 320);
    if (controller.focusNode == null) {
      return Offset(screen.width / 2, screen.height / 2);
    }

    try {
      final horizontal = controller.horizontalScrollController;
      final vertical = controller.verticalScrollController;
      return Offset(
        horizontal.offset + screen.width / 2,
        vertical.offset + screen.height / 2,
      );
    } catch (_) {
      return Offset(screen.width / 2, screen.height / 2);
    }
  }

  static void fitToView(NodeEditorController controller) {
    if (controller.nodes.isEmpty) return;

    var minX = double.infinity;
    var minY = double.infinity;
    for (final node in controller.nodes.values) {
      minX = minX < node.pos.dx ? minX : node.pos.dx;
      minY = minY < node.pos.dy ? minY : node.pos.dy;
    }

    try {
      final horizontal = controller.horizontalScrollController;
      final vertical = controller.verticalScrollController;
      if (!horizontal.hasClients || !vertical.hasClients) return;

      horizontal.jumpTo(
        (minX - 80).clamp(0.0, horizontal.position.maxScrollExtent),
      );
      vertical.jumpTo(
        (minY - 80).clamp(0.0, vertical.position.maxScrollExtent),
      );
      controller.notify();
    } catch (_) {
      return;
    }
  }

  static void scrollToNode(NodeEditorController controller, String nodeId) {
    final node = controller.nodes[nodeId];
    if (node == null) return;

    try {
      final horizontal = controller.horizontalScrollController;
      final vertical = controller.verticalScrollController;
      if (!horizontal.hasClients || !vertical.hasClients) return;

      horizontal.animateTo(
        (node.pos.dx - 120).clamp(0.0, horizontal.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      vertical.animateTo(
        (node.pos.dy - 120).clamp(0.0, vertical.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } catch (_) {
      return;
    }
  }

  static void _afterPortsReady(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => callback());
    });
  }

  static void _restoreConnections(
    NodeEditorController controller,
    List<GraphEdge> edges,
  ) {
    for (final edge in edges) {
      final outNode = controller.nodes[edge.fromNode];
      final inNode = controller.nodes[edge.toNode];
      if (outNode == null || inNode == null) continue;

      final outPort = outNode.ports[edge.fromPort];
      final inPort = inNode.ports[edge.toPort];
      if (outPort == null || inPort == null) continue;

      final exists = controller.connections.any(
        (connection) =>
            connection.outNode.name == edge.fromNode &&
            connection.outPort.name == edge.fromPort &&
            connection.inNode.name == edge.toNode &&
            connection.inPort.name == edge.toPort,
      );
      if (exists) continue;

      controller.connectionsManager.connections.add(
        Connection(
          inNode: inNode,
          inPort: inPort,
          outNode: outNode,
          outPort: outPort,
        ),
      );
    }
  }
}

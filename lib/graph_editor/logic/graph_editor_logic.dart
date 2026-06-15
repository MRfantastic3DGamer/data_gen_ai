import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/port_type.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:uuid/uuid.dart';

class GraphConnectionValidation {
  const GraphConnectionValidation({required this.isValid, this.reason});

  final bool isValid;
  final String? reason;
}

class GraphEditorLogic {
  const GraphEditorLogic._();

  static const _uuid = Uuid();

  static String nextId(String prefix) => '$prefix-${_uuid.v4().substring(0, 8)}';

  static GraphNode createNode(String typeId, GraphPosition position) {
    final definition = NodeRegistry.byTypeId(typeId);
    return GraphNode(
      id: nextId('node'),
      type: typeId,
      position: position,
      options: _deepCopyOptions(definition?.defaultOptions ?? const {}),
    );
  }

  static GraphDocument addNode(GraphDocument doc, GraphNode node) {
    final nodes = List<GraphNode>.from(doc.nodes)..add(node);
    return doc.copyWith(nodes: nodes);
  }

  static GraphDocument removeNode(GraphDocument doc, String nodeId) {
    return doc.copyWith(
      nodes: doc.nodes.where((n) => n.id != nodeId).toList(),
      edges: doc.edges
          .where((e) => e.fromNode != nodeId && e.toNode != nodeId)
          .toList(),
    );
  }

  static GraphConnectionValidation validateConnection({
    required GraphDocument doc,
    required String fromNodeId,
    required String fromPort,
    required String toNodeId,
    required String toPort,
  }) {
    if (fromNodeId == toNodeId) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Cannot connect a node to itself',
      );
    }

    final fromNode = doc.nodeById(fromNodeId);
    final toNode = doc.nodeById(toNodeId);
    if (fromNode == null || toNode == null) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Unknown node',
      );
    }

    if (_isStructuralConnection(fromPort, toPort)) {
      return _validateStructuralConnection(
        doc: doc,
        fromNode: fromNode,
        toNode: toNode,
        fromPort: fromPort,
        toPort: toPort,
      );
    }

    final fromDef = NodeRegistry.byTypeId(fromNode.type);
    final toDef = NodeRegistry.byTypeId(toNode.type);
    if (fromDef == null || toDef == null) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Unknown node type',
      );
    }

    final fromPortDef = fromDef.portByName(fromPort, fromNode.options);
    final toPortDef = toDef.portByName(toPort, toNode.options);
    if (fromPortDef == null || toPortDef == null) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Unknown port',
      );
    }

    if (!fromPortDef.canConnectTo(toPortDef)) {
      return GraphConnectionValidation(
        isValid: false,
        reason:
            'Incompatible ports: ${fromPortDef.type.label} cannot connect to ${toPortDef.type.label}',
      );
    }

    final outputNode = fromPortDef.direction == PortDirection.output
        ? fromNodeId
        : toNodeId;
    final outputPort = fromPortDef.direction == PortDirection.output
        ? fromPort
        : toPort;
    final inputNode = fromPortDef.direction == PortDirection.input
        ? fromNodeId
        : toNodeId;
    final inputPort = fromPortDef.direction == PortDirection.input
        ? fromPort
        : toPort;
    final inputDef = fromPortDef.direction == PortDirection.input
        ? fromPortDef
        : toPortDef;

    if (!inputDef.multiCapacity) {
      final occupied = doc.edges.any(
        (e) => e.toNode == inputNode && e.toPort == inputPort,
      );
      if (occupied) {
        return const GraphConnectionValidation(
          isValid: false,
          reason: 'Input port already connected',
        );
      }
    }

    final duplicate = doc.edges.any(
      (e) =>
          e.fromNode == outputNode &&
          e.fromPort == outputPort &&
          e.toNode == inputNode &&
          e.toPort == inputPort,
    );
    if (duplicate) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Connection already exists',
      );
    }

    return const GraphConnectionValidation(isValid: true);
  }

  static bool _isStructuralConnection(String fromPort, String toPort) {
    return fromPort == StructuralPorts.blocks && toPort == StructuralPorts.block;
  }

  static GraphConnectionValidation _validateStructuralConnection({
    required GraphDocument doc,
    required GraphNode fromNode,
    required GraphNode toNode,
    required String fromPort,
    required String toPort,
  }) {
    if (fromPort != StructuralPorts.blocks || toPort != StructuralPorts.block) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Invalid structural port pair',
      );
    }

    final fromDef = NodeRegistry.byTypeId(fromNode.type);
    final toDef = NodeRegistry.byTypeId(toNode.type);
    if (fromDef == null || toDef == null) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Unknown node type',
      );
    }

    if (!fromDef.isContextNode) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Blocks port is only on context nodes',
      );
    }

    if (!toDef.isBlockNode) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Block port is only on block nodes',
      );
    }

    if (toDef.parentContextTypeId != fromNode.type) {
      return GraphConnectionValidation(
        isValid: false,
        reason:
            '${toDef.displayName} blocks attach to ${NodeRegistry.byTypeId(toDef.parentContextTypeId!)?.displayName ?? 'parent context'}',
      );
    }

    final blockOccupied = doc.edges.any(
      (e) => e.toNode == toNode.id && e.toPort == StructuralPorts.block,
    );
    if (blockOccupied) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Block already attached to a context',
      );
    }

    final duplicate = doc.edges.any(
      (e) =>
          e.fromNode == fromNode.id &&
          e.fromPort == StructuralPorts.blocks &&
          e.toNode == toNode.id &&
          e.toPort == StructuralPorts.block,
    );
    if (duplicate) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Connection already exists',
      );
    }

    return const GraphConnectionValidation(isValid: true);
  }

  static GraphDocument addEdge(
    GraphDocument doc, {
    required String fromNodeId,
    required String fromPort,
    required String toNodeId,
    required String toPort,
  }) {
    final validation = validateConnection(
      doc: doc,
      fromNodeId: fromNodeId,
      fromPort: fromPort,
      toNodeId: toNodeId,
      toPort: toPort,
    );
    if (!validation.isValid) return doc;

    if (_isStructuralConnection(fromPort, toPort)) {
      return doc.copyWith(
        edges: List<GraphEdge>.from(doc.edges)
          ..add(
            GraphEdge(
              fromNode: fromNodeId,
              fromPort: fromPort,
              toNode: toNodeId,
              toPort: toPort,
            ),
          ),
      );
    }

    final fromNode = doc.nodeById(fromNodeId)!;
    final fromDef = NodeRegistry.byTypeId(fromNode.type)!;
    final fromPortDef = fromDef.portByName(fromPort, fromNode.options)!;

    final normalized = fromPortDef.direction == PortDirection.output
        ? GraphEdge(
            fromNode: fromNodeId,
            fromPort: fromPort,
            toNode: toNodeId,
            toPort: toPort,
          )
        : GraphEdge(
            fromNode: toNodeId,
            fromPort: toPort,
            toNode: fromNodeId,
            toPort: fromPort,
          );

    return doc.copyWith(edges: List<GraphEdge>.from(doc.edges)..add(normalized));
  }

  static GraphDocument removeEdge(GraphDocument doc, GraphEdge edge) {
    return doc.copyWith(
      edges: doc.edges
          .where(
            (e) =>
                !(e.fromNode == edge.fromNode &&
                    e.fromPort == edge.fromPort &&
                    e.toNode == edge.toNode &&
                    e.toPort == edge.toPort),
          )
          .toList(),
    );
  }

  static Map<String, dynamic> _deepCopyOptions(Map<String, dynamic> source) {
    return source.map((key, value) {
      if (value is Map) {
        return MapEntry(
          key,
          Map<String, dynamic>.from(
            value.map((k, v) => MapEntry(k.toString(), v)),
          ),
        );
      }
      return MapEntry(key, value);
    });
  }
}

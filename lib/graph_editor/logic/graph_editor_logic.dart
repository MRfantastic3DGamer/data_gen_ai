import 'package:data_gen_ai/graph_editor/models/graph_block.dart';
import 'package:data_gen_ai/graph_editor/models/graph_context.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
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

  static GraphBlock createBlock(String typeId) {
    final definition = NodeRegistry.byTypeId(typeId);
    return GraphBlock(
      id: nextId('block'),
      type: typeId,
      options: _deepCopyOptions(definition?.defaultOptions ?? const {}),
    );
  }

  static GraphDocument addNode(GraphDocument doc, GraphNode node) {
    final nodes = List<GraphNode>.from(doc.nodes)..add(node);
    var contexts = List<GraphContext>.from(doc.contexts);
    final definition = NodeRegistry.byTypeId(node.type);
    if (definition?.isContextNode == true &&
        !contexts.any((c) => c.parentNodeId == node.id)) {
      contexts = List<GraphContext>.from(contexts)
        ..add(GraphContext(parentNodeId: node.id));
    }
    return doc.copyWith(nodes: nodes, contexts: contexts);
  }

  static GraphDocument removeNode(GraphDocument doc, String nodeId) {
    return doc.copyWith(
      nodes: doc.nodes.where((n) => n.id != nodeId).toList(),
      edges: doc.edges
          .where((e) => e.fromNode != nodeId && e.toNode != nodeId)
          .toList(),
      contexts: doc.contexts
          .where((c) => c.parentNodeId != nodeId)
          .map(
            (c) => c.copyWith(
              blocks: c.blocks.where((b) => b.id != nodeId).toList(),
            ),
          )
          .toList(),
    );
  }

  static GraphDocument addBlock(
    GraphDocument doc,
    String parentNodeId,
    GraphBlock block,
  ) {
    final contexts = List<GraphContext>.from(doc.contexts);
    final index = contexts.indexWhere((c) => c.parentNodeId == parentNodeId);
    if (index < 0) {
      contexts.add(GraphContext(parentNodeId: parentNodeId, blocks: [block]));
    } else {
      final context = contexts[index];
      contexts[index] = context.copyWith(
        blocks: List<GraphBlock>.from(context.blocks)..add(block),
      );
    }
    return doc.copyWith(contexts: contexts);
  }

  static GraphDocument removeBlock(
    GraphDocument doc,
    String parentNodeId,
    String blockId,
  ) {
    final contexts = doc.contexts.map((context) {
      if (context.parentNodeId != parentNodeId) return context;
      return context.copyWith(
        blocks: context.blocks.where((b) => b.id != blockId).toList(),
      );
    }).toList();
    return doc.copyWith(
      contexts: contexts,
      edges: doc.edges
          .where((e) => e.fromNode != blockId && e.toNode != blockId)
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

    final from = _resolveElement(doc, fromNodeId);
    final to = _resolveElement(doc, toNodeId);
    if (from == null || to == null) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Unknown node or block',
      );
    }

    final fromDef = NodeRegistry.byTypeId(from.type);
    final toDef = NodeRegistry.byTypeId(to.type);
    if (fromDef == null || toDef == null) {
      return const GraphConnectionValidation(
        isValid: false,
        reason: 'Unknown node type',
      );
    }

    final fromPortDef = fromDef.portByName(fromPort, from.options);
    final toPortDef = toDef.portByName(toPort, to.options);
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

    final fromDef = NodeRegistry.byTypeId(
      _resolveElement(doc, fromNodeId)!.type,
    )!;
    final fromPortDef = fromDef.portByName(
      fromPort,
      _resolveElement(doc, fromNodeId)!.options,
    )!;

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

  static _GraphElement? _resolveElement(GraphDocument doc, String id) {
    final node = doc.nodeById(id);
    if (node != null) return _GraphElement(type: node.type, options: node.options);
    for (final context in doc.contexts) {
      for (final block in context.blocks) {
        if (block.id == id) {
          return _GraphElement(type: block.type, options: block.options);
        }
      }
    }
    return null;
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

class _GraphElement {
  const _GraphElement({required this.type, required this.options});

  final String type;
  final Map<String, dynamic> options;
}

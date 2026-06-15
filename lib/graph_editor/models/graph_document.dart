import 'package:data_gen_ai/graph_editor/models/graph_context.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/node_editor/graph_document_migration.dart';

class GraphDocument {
  const GraphDocument({
    required this.graphName,
    this.nodes = const <GraphNode>[],
    this.edges = const <GraphEdge>[],
    this.contexts = const <GraphContext>[],
  });

  final String graphName;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final List<GraphContext> contexts;

  factory GraphDocument.empty({String graphName = 'NewGraph'}) {
    return GraphDocument(graphName: graphName);
  }

  factory GraphDocument.fromJson(Map<String, dynamic> json) {
    final document = GraphDocument(
      graphName: json['graphName'] as String? ?? 'Untitled',
      nodes: (json['nodes'] as List? ?? const <dynamic>[])
          .map((e) => GraphNode.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      edges: (json['edges'] as List? ?? const <dynamic>[])
          .map((e) => GraphEdge.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      contexts: (json['contexts'] as List? ?? const <dynamic>[])
          .map((e) => GraphContext.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
    return GraphDocumentMigration.migrateLegacyContexts(document);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'graphName': graphName,
    'nodes': nodes.map((n) => n.toJson()).toList(),
    'edges': edges.map((e) => e.toJson()).toList(),
    'contexts': contexts.map((c) => c.toJson()).toList(),
  };

  GraphDocument copyWith({
    String? graphName,
    List<GraphNode>? nodes,
    List<GraphEdge>? edges,
    List<GraphContext>? contexts,
  }) {
    return GraphDocument(
      graphName: graphName ?? this.graphName,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      contexts: contexts ?? this.contexts,
    );
  }

  GraphNode? nodeById(String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }

  GraphContext? contextForNode(String nodeId) {
    for (final context in contexts) {
      if (context.parentNodeId == nodeId) return context;
    }
    return null;
  }
}

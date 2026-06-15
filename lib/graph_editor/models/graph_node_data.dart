import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';

class GraphNodeData {
  GraphNodeData({
    required this.unityTypeId,
    Map<String, dynamic>? options,
  }) : options = options ?? <String, dynamic>{};

  final String unityTypeId;
  final Map<String, dynamic> options;

  NodeTypeDefinition? get definition => NodeRegistry.byTypeId(unityTypeId);

  String get displayName => definition?.displayName ?? unityTypeId;

  factory GraphNodeData.fromGraphNode(GraphNode node) {
    return GraphNodeData(
      unityTypeId: node.type,
      options: Map<String, dynamic>.from(node.options),
    );
  }

  GraphNode toGraphNode({
    required String id,
    required double x,
    required double y,
  }) {
    return GraphNode(
      id: id,
      type: unityTypeId,
      position: GraphPosition(x: x, y: y),
      options: Map<String, dynamic>.from(options),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'unityTypeId': unityTypeId,
    'options': options,
  };

  factory GraphNodeData.fromJson(Map<String, dynamic> json) {
    return GraphNodeData(
      unityTypeId: json['unityTypeId'] as String,
      options: Map<String, dynamic>.from(
        json['options'] as Map? ?? const <String, dynamic>{},
      ),
    );
  }

  GraphNodeData copyWith({
    String? unityTypeId,
    Map<String, dynamic>? options,
  }) {
    return GraphNodeData(
      unityTypeId: unityTypeId ?? this.unityTypeId,
      options: options ?? this.options,
    );
  }
}

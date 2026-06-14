import 'package:data_gen_ai/graph_editor/models/graph_position.dart';

class GraphNode {
  const GraphNode({
    required this.id,
    required this.type,
    required this.position,
    this.options = const <String, dynamic>{},
  });

  final String id;
  final String type;
  final GraphPosition position;
  final Map<String, dynamic> options;

  factory GraphNode.fromJson(Map<String, dynamic> json) {
    return GraphNode(
      id: json['id'] as String,
      type: json['type'] as String,
      position: GraphPosition.fromJson(
        Map<String, dynamic>.from(json['position'] as Map? ?? const {}),
      ),
      options: Map<String, dynamic>.from(
        json['options'] as Map? ?? const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type,
    'position': position.toJson(),
    'options': options,
  };

  GraphNode copyWith({
    String? id,
    String? type,
    GraphPosition? position,
    Map<String, dynamic>? options,
  }) {
    return GraphNode(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      options: options ?? this.options,
    );
  }
}

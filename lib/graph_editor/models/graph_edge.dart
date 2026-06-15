class GraphEdge {
  const GraphEdge({
    required this.fromNode,
    required this.fromPort,
    required this.toNode,
    required this.toPort,
  });

  final String fromNode;
  final String fromPort;
  final String toNode;
  final String toPort;

  factory GraphEdge.fromJson(Map<String, dynamic> json) {
    return GraphEdge(
      fromNode: json['fromNode'] as String,
      fromPort: json['fromPort'] as String,
      toNode: json['toNode'] as String,
      toPort: json['toPort'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'fromNode': fromNode,
    'fromPort': fromPort,
    'toNode': toNode,
    'toPort': toPort,
  };

  GraphEdge copyWith({
    String? fromNode,
    String? fromPort,
    String? toNode,
    String? toPort,
  }) {
    return GraphEdge(
      fromNode: fromNode ?? this.fromNode,
      fromPort: fromPort ?? this.fromPort,
      toNode: toNode ?? this.toNode,
      toPort: toPort ?? this.toPort,
    );
  }
}

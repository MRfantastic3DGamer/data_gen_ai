import 'package:data_gen_ai/graph_editor/models/graph_block.dart';

class GraphContext {
  const GraphContext({
    required this.parentNodeId,
    this.blocks = const <GraphBlock>[],
  });

  final String parentNodeId;
  final List<GraphBlock> blocks;

  factory GraphContext.fromJson(Map<String, dynamic> json) {
    return GraphContext(
      parentNodeId: json['parentNodeId'] as String,
      blocks: (json['blocks'] as List? ?? const <dynamic>[])
          .map((e) => GraphBlock.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'parentNodeId': parentNodeId,
    'blocks': blocks.map((b) => b.toJson()).toList(),
  };

  GraphContext copyWith({
    String? parentNodeId,
    List<GraphBlock>? blocks,
  }) {
    return GraphContext(
      parentNodeId: parentNodeId ?? this.parentNodeId,
      blocks: blocks ?? this.blocks,
    );
  }
}

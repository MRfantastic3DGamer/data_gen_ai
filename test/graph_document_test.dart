import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('graph document serializes to expected JSON shape', () {
    final document = GraphDocument(
      graphName: 'Aggressive_Brawler_Pattern',
      nodes: <GraphNode>[
        GraphNode(
          id: 'node-1',
          type: CharacterDesignNodeTypes.sensedAgentQueryNode,
          position: const GraphPosition(x: 100, y: 100),
          options: const <String, dynamic>{
            'Query': <String, dynamic>{'someValue': 5},
          },
        ),
        GraphNode(
          id: 'node-2',
          type: CharacterDesignNodeTypes.beliefNode,
          position: const GraphPosition(x: 400, y: 100),
        ),
      ],
      edges: const <GraphEdge>[
        GraphEdge(
          fromNode: 'node-1',
          fromPort: 'Query',
          toNode: 'node-2',
          toPort: 'Query',
        ),
      ],
    );

    final json = document.toJson();
    expect(json['graphName'], 'Aggressive_Brawler_Pattern');
    expect(json['nodes'], isA<List<dynamic>>());
    expect(json['edges'], isA<List<dynamic>>());
    expect(json['contexts'], isA<List<dynamic>>());
    expect((json['nodes'] as List).first['type'], contains('SensedAgentQueryNode'));

    final roundTrip = GraphDocument.fromJson(json);
    expect(roundTrip.graphName, document.graphName);
    expect(roundTrip.nodes.length, 2);
    expect(roundTrip.edges.length, 1);
  });
}

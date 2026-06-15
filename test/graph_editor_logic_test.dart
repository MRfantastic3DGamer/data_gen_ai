import 'package:data_gen_ai/graph_editor/logic/graph_editor_logic.dart';
import 'package:data_gen_ai/graph_editor/models/graph_block.dart';
import 'package:data_gen_ai/graph_editor/models/graph_context.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('block ports can be connected to node ports via edges', () {
    final profileNode = GraphNode(
      id: 'node-profile',
      type: CharacterDesignNodeTypes.characterProfileNode,
      position: const GraphPosition(x: 0, y: 0),
    );
    final variantBlock = GraphBlock(
      id: 'block-variant',
      type: CharacterDesignNodeTypes.characterVariantBlock,
    );
    final queryNode = GraphNode(
      id: 'node-query',
      type: CharacterDesignNodeTypes.sensedAgentQueryNode,
      position: const GraphPosition(x: 300, y: 0),
    );
    final beliefNode = GraphNode(
      id: 'node-belief',
      type: CharacterDesignNodeTypes.beliefNode,
      position: const GraphPosition(x: 600, y: 0),
    );

    var document = GraphDocument(
      graphName: 'BlockEdges',
      nodes: <GraphNode>[profileNode, queryNode, beliefNode],
      contexts: <GraphContext>[
        GraphContext(
          parentNodeId: 'node-character',
          blocks: <GraphBlock>[variantBlock],
        ),
      ],
    );

    document = GraphEditorLogic.addEdge(
      document,
      fromNodeId: 'node-profile',
      fromPort: 'Profile',
      toNodeId: variantBlock.id,
      toPort: 'Profile',
    );
    document = GraphEditorLogic.addEdge(
      document,
      fromNodeId: 'node-query',
      fromPort: 'Query',
      toNodeId: 'node-belief',
      toPort: 'Query',
    );

    expect(document.edges, hasLength(2));
    expect(document.edges.first.toNode, variantBlock.id);
    expect(document.edges.last.fromNode, 'node-query');
  });

  test('rejects incompatible port types', () {
    final document = GraphDocument(
      graphName: 'Invalid',
      nodes: <GraphNode>[
        GraphNode(
          id: 'node-query',
          type: CharacterDesignNodeTypes.sensedAgentQueryNode,
          position: const GraphPosition(x: 0, y: 0),
        ),
        GraphNode(
          id: 'node-belief',
          type: CharacterDesignNodeTypes.beliefNode,
          position: const GraphPosition(x: 200, y: 0),
        ),
      ],
    );

    final validation = GraphEditorLogic.validateConnection(
      doc: document,
      fromNodeId: 'node-belief',
      fromPort: 'Belief',
      toNodeId: 'node-query',
      toPort: 'Query',
    );

    expect(validation.isValid, isFalse);
  });
}

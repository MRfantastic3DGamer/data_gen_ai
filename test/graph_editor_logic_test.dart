import 'package:data_gen_ai/graph_editor/logic/graph_editor_logic.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('block nodes connect to context via Blocks→Block edges', () {
    final characterNode = GraphNode(
      id: 'node-character',
      type: CharacterDesignNodeTypes.characterDefinition,
      position: const GraphPosition(x: 0, y: 0),
    );
    final variantBlock = GraphNode(
      id: 'block-variant',
      type: CharacterDesignNodeTypes.characterVariantBlock,
      position: const GraphPosition(x: 0, y: 200),
    );
    final profileNode = GraphNode(
      id: 'node-profile',
      type: CharacterDesignNodeTypes.characterProfileNode,
      position: const GraphPosition(x: 300, y: 0),
    );

    var document = GraphDocument(
      graphName: 'BlockEdges',
      nodes: <GraphNode>[characterNode, variantBlock, profileNode],
    );

    final attachment = GraphEditorLogic.validateConnection(
      doc: document,
      fromNodeId: characterNode.id,
      fromPort: StructuralPorts.blocks,
      toNodeId: variantBlock.id,
      toPort: StructuralPorts.block,
    );
    expect(attachment.isValid, isTrue);

    document = GraphEditorLogic.addEdge(
      document,
      fromNodeId: characterNode.id,
      fromPort: StructuralPorts.blocks,
      toNodeId: variantBlock.id,
      toPort: StructuralPorts.block,
    );

    document = GraphEditorLogic.addEdge(
      document,
      fromNodeId: profileNode.id,
      fromPort: 'Profile',
      toNodeId: variantBlock.id,
      toPort: 'Profile',
    );

    expect(document.edges, hasLength(2));
    expect(
      document.edges.any(
        (e) =>
            e.fromPort == StructuralPorts.blocks &&
            e.toPort == StructuralPorts.block,
      ),
      isTrue,
    );
  });

  test('rejects block attached to wrong context type', () {
    final profileNode = GraphNode(
      id: 'node-profile',
      type: CharacterDesignNodeTypes.characterProfileNode,
      position: const GraphPosition(x: 0, y: 0),
    );
    final variantBlock = GraphNode(
      id: 'block-variant',
      type: CharacterDesignNodeTypes.characterVariantBlock,
      position: const GraphPosition(x: 0, y: 200),
    );

    final document = GraphDocument(
      graphName: 'WrongContext',
      nodes: <GraphNode>[profileNode, variantBlock],
    );

    final validation = GraphEditorLogic.validateConnection(
      doc: document,
      fromNodeId: profileNode.id,
      fromPort: StructuralPorts.blocks,
      toNodeId: variantBlock.id,
      toPort: StructuralPorts.block,
    );

    expect(validation.isValid, isFalse);
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

import 'package:data_gen_ai/graph_editor/models/graph_block.dart';
import 'package:data_gen_ai/graph_editor/models/graph_context.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/vyuh/vyuh_graph_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('migrates legacy nested contexts to block nodes and attachment edges', () {
    final characterNode = GraphNode(
      id: 'node-character',
      type: CharacterDesignNodeTypes.characterDefinition,
      position: const GraphPosition(x: 0, y: 0),
    );
    final variantBlock = GraphBlock(
      id: 'block-variant',
      type: CharacterDesignNodeTypes.characterVariantBlock,
    );

    final legacy = GraphDocument(
      graphName: 'Legacy',
      nodes: <GraphNode>[characterNode],
      contexts: <GraphContext>[
        GraphContext(parentNodeId: characterNode.id, blocks: <GraphBlock>[variantBlock]),
      ],
    );

    final migrated = VyuhGraphAdapter.migrateLegacyContexts(legacy);

    expect(migrated.contexts, isEmpty);
    expect(migrated.nodes, hasLength(2));
    expect(migrated.nodeById(variantBlock.id), isNotNull);
    expect(
      migrated.edges.any(
        (e) =>
            e.fromNode == characterNode.id &&
            e.fromPort == StructuralPorts.blocks &&
            e.toNode == variantBlock.id &&
            e.toPort == StructuralPorts.block,
      ),
      isTrue,
    );
  });
}

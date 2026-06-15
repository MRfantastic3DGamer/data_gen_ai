import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/node_editor/character_design_node_factory.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:node_editor/node_editor.dart';

void main() {
  test('context node widget includes Blocks output port', () {
    final node = GraphNode(
      id: 'context-1',
      type: CharacterDesignNodeTypes.characterDefinition,
      position: const GraphPosition(x: 0, y: 0),
    );

    final widget = CharacterDesignNodeFactory.build(
      node,
      onConnect: ({
        required String fromNodeId,
        required String fromPort,
        required String toNodeId,
        required String toPort,
      }) =>
          true,
    );

    expect(widget, isA<ContainerNodeWidget>());
    expect(widget.name, 'context-1');
    expect(widget.typeName, CharacterDesignNodeTypes.characterDefinition);
  });

  test('block node widget includes Block input port', () {
    final node = GraphNode(
      id: 'block-1',
      type: CharacterDesignNodeTypes.characterVariantBlock,
      position: const GraphPosition(x: 40, y: 120),
    );

    final widget = CharacterDesignNodeFactory.build(
      node,
      onConnect: ({
        required String fromNodeId,
        required String fromPort,
        required String toNodeId,
        required String toPort,
      }) =>
          true,
    );

    expect(widget, isA<ContainerNodeWidget>());
    expect(widget.name, 'block-1');
    expect(widget.typeName, CharacterDesignNodeTypes.characterVariantBlock);
  });

  test('structural port names match graph edge conventions', () {
    expect(StructuralPorts.blocks, 'Blocks');
    expect(StructuralPorts.block, 'Block');
  });
}

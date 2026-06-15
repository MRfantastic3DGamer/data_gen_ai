import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/vyuh/graph_node_layout.dart';
import 'package:data_gen_ai/graph_editor/vyuh/vyuh_port_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as vyuh;

void main() {
  group('GraphNodeLayout', () {
    test('data port rows align with vyuh vertical offsets', () {
      expect(GraphNodeLayout.rowCenterY(0), 66);
      expect(GraphNodeLayout.rowCenterY(1), 94);
      expect(
        GraphNodeLayout.portCenterOffset(rowIndex: 0),
        const Offset(0, 66),
      );
    });

    test('structural ports use edge-centered offsets', () {
      expect(
        GraphNodeLayout.blockPortCenter(),
        const Offset(GraphNodeLayout.nodeWidth / 2, 0),
      );
      expect(
        GraphNodeLayout.blocksPortCenter(),
        const Offset(GraphNodeLayout.nodeWidth / 2, 0),
      );
    });

    test('context node exposes bottom Blocks and aligned data ports', () {
      final ports = VyuhPortBuilder.buildPorts(
        CharacterDesignNodeTypes.characterDefinition,
        const <String, dynamic>{},
      );

      final blocks = ports.singleWhere((p) => p.id == StructuralPorts.blocks);
      expect(blocks.position, vyuh.PortPosition.bottom);
      expect(blocks.offset, GraphNodeLayout.blocksPortCenter());
    });

    test('block node exposes top Block port', () {
      final ports = VyuhPortBuilder.buildPorts(
        CharacterDesignNodeTypes.characterVariantBlock,
        const <String, dynamic>{},
      );

      final block = ports.singleWhere((p) => p.id == StructuralPorts.block);
      expect(block.position, vyuh.PortPosition.top);
      expect(block.offset, GraphNodeLayout.blockPortCenter());
    });
  });
}

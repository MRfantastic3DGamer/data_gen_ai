import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/port_type.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/vyuh/graph_node_layout.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as vyuh;

abstract final class VyuhPortBuilder {
  static List<vyuh.Port> buildPorts(
    String unityTypeId,
    Map<String, dynamic> options,
  ) {
    final definition = NodeRegistry.byTypeId(unityTypeId);
    if (definition == null) return <vyuh.Port>[];

    final height = GraphNodeLayout.nodeHeight(unityTypeId, options);
    final ports = <vyuh.Port>[];
    final dataPorts = GraphNodeLayout.dataPorts(unityTypeId, options);

    if (definition.isBlockNode) {
      ports.add(_structuralPort(
        id: StructuralPorts.block,
        name: StructuralPorts.block,
        type: vyuh.PortType.input,
        position: vyuh.PortPosition.top,
        center: GraphNodeLayout.blockPortCenter(),
        tooltip: 'Connect from a context Blocks port',
      ));
    }

    for (var i = 0; i < dataPorts.length; i++) {
      final portDef = dataPorts[i];
      final isInput = portDef.direction == PortDirection.input;
      ports.add(
        vyuh.Port(
          id: portDef.name,
          name: portDef.name,
          type: isInput ? vyuh.PortType.input : vyuh.PortType.output,
          position: isInput ? vyuh.PortPosition.left : vyuh.PortPosition.right,
          offset: GraphNodeLayout.portCenterOffset(rowIndex: i),
          multiConnections: portDef.multiCapacity,
          showLabel: false,
          tooltip: portDef.type.label,
        ),
      );
    }

    if (definition.isContextNode) {
      ports.add(_structuralPort(
        id: StructuralPorts.blocks,
        name: StructuralPorts.blocks,
        type: vyuh.PortType.output,
        position: vyuh.PortPosition.bottom,
        center: GraphNodeLayout.blocksPortCenter(),
        multiConnections: true,
        tooltip: 'Attach block nodes below this context',
      ));
    }

    return ports;
  }

  static vyuh.Port _structuralPort({
    required String id,
    required String name,
    required vyuh.PortType type,
    required vyuh.PortPosition position,
    required Offset center,
    bool multiConnections = false,
    String? tooltip,
  }) {
    return vyuh.Port(
      id: id,
      name: name,
      type: type,
      position: position,
      offset: center,
      multiConnections: multiConnections,
      showLabel: false,
      tooltip: tooltip,
    );
  }
}

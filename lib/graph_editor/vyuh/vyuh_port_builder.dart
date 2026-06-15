import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/port_type.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart' as vyuh;

abstract final class VyuhPortBuilder {
  static List<vyuh.Port> buildPorts(
    String unityTypeId,
    Map<String, dynamic> options,
  ) {
    final definition = NodeRegistry.byTypeId(unityTypeId);
    if (definition == null) return <vyuh.Port>[];

    final ports = <vyuh.Port>[];

    if (definition.isBlockNode) {
      ports.add(
        vyuh.Port(
          id: StructuralPorts.block,
          name: StructuralPorts.block,
          type: vyuh.PortType.input,
          position: vyuh.PortPosition.top,
          tooltip: 'Connect from a context node Blocks port',
        ),
      );
    }

    for (final portDef in definition.resolvePorts(options)) {
      ports.add(
        vyuh.Port(
          id: portDef.name,
          name: portDef.name,
          type: portDef.direction == PortDirection.input
              ? vyuh.PortType.input
              : vyuh.PortType.output,
          position: portDef.direction == PortDirection.input
              ? vyuh.PortPosition.left
              : vyuh.PortPosition.right,
          multiConnections: portDef.multiCapacity,
          tooltip: portDef.type.label,
        ),
      );
    }

    if (definition.isContextNode) {
      ports.add(
        vyuh.Port(
          id: StructuralPorts.blocks,
          name: StructuralPorts.blocks,
          type: vyuh.PortType.output,
          position: vyuh.PortPosition.bottom,
          multiConnections: true,
          tooltip: 'Attach block nodes below this context',
        ),
      );
    }

    return ports;
  }
}

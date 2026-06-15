import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

abstract final class VyuhPortBuilder {
  static List<Port> buildPorts(String unityTypeId, Map<String, dynamic> options) {
    final definition = NodeRegistry.byTypeId(unityTypeId);
    if (definition == null) return const <Port>[];

    final ports = <Port>[];

    if (definition.isBlockNode) {
      ports.add(
        const Port(
          id: StructuralPorts.block,
          name: StructuralPorts.block,
          type: PortType.input,
          position: PortPosition.top,
          tooltip: 'Connect from a context node Blocks port',
        ),
      );
    }

    for (final portDef in definition.resolvePorts(options)) {
      ports.add(
        Port(
          id: portDef.name,
          name: portDef.name,
          type: portDef.direction == PortDirection.input
              ? PortType.input
              : PortType.output,
          position: portDef.direction == PortDirection.input
              ? PortPosition.left
              : PortPosition.right,
          multiConnections: portDef.multiCapacity,
          tooltip: portDef.type.label,
        ),
      );
    }

    if (definition.isContextNode) {
      ports.add(
        const Port(
          id: StructuralPorts.blocks,
          name: StructuralPorts.blocks,
          type: PortType.output,
          position: PortPosition.bottom,
          multiConnections: true,
          tooltip: 'Attach block nodes below this context',
        ),
      );
    }

    return ports;
  }
}

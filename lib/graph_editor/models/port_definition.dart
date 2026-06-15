import 'package:data_gen_ai/graph_editor/models/port_type.dart';

enum PortDirection { input, output }

class PortDefinition {
  const PortDefinition({
    required this.name,
    required this.direction,
    required this.type,
    this.multiCapacity = false,
  });

  final String name;
  final PortDirection direction;
  final PortType type;
  final bool multiCapacity;

  bool canConnectTo(PortDefinition other) {
    if (direction == other.direction) return false;
    return type.isCompatibleWith(other.type);
  }
}

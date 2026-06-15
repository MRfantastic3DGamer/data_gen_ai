import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:flutter/material.dart';

/// Shared layout constants for graph nodes. Port offsets and row UI must stay
/// in sync so vyuh can place handles on the correct row edges.
abstract final class GraphNodeLayout {
  static const nodeWidth = 240.0;
  static const headerHeight = 44.0;
  static const rowHeight = 28.0;
  static const bodyPadding = 8.0;
  static const portHorizontalInset = 0.0;

  static int dataPortCount(String unityTypeId, Map<String, dynamic> options) {
    return NodeRegistry.byTypeId(unityTypeId)?.resolvePorts(options).length ?? 0;
  }

  static double nodeHeight(String unityTypeId, Map<String, dynamic> options) {
    final dataRows = dataPortCount(unityTypeId, options);
    if (dataRows == 0) {
      return headerHeight + bodyPadding * 2;
    }
    return headerHeight + bodyPadding * 2 + dataRows * rowHeight;
  }

  static Size nodeSize(String unityTypeId, Map<String, dynamic> options) {
    return Size(nodeWidth, nodeHeight(unityTypeId, options));
  }

  /// Vertical center of a data port row in node-local coordinates.
  static double rowCenterY(int rowIndex) {
    return headerHeight + bodyPadding + rowIndex * rowHeight + rowHeight / 2;
  }

  /// Offset for vyuh [Port.offset] — port center in node-local coordinates.
  ///
  /// Left/right ports use [Offset.dx] as a horizontal edge adjustment and
  /// [Offset.dy] as the vertical center. Top/bottom ports use [Offset.dx] as
  /// the horizontal center and [Offset.dy] as a vertical edge adjustment.
  static Offset portCenterOffset({
    required int rowIndex,
  }) {
    return Offset(portHorizontalInset, rowCenterY(rowIndex));
  }

  static Offset blockPortCenter() {
    return Offset(nodeWidth / 2, 0);
  }

  static Offset blocksPortCenter() {
    return Offset(nodeWidth / 2, 0);
  }

  static List<PortDefinition> dataPorts(
    String unityTypeId,
    Map<String, dynamic> options,
  ) {
    return NodeRegistry.byTypeId(unityTypeId)?.resolvePorts(options) ??
        const <PortDefinition>[];
  }

  static bool isStructuralPortId(String portId) {
    return portId == StructuralPorts.block || portId == StructuralPorts.blocks;
  }
}

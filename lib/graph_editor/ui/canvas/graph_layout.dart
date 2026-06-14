import 'dart:math' as math;

import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:flutter/material.dart';

class GraphLayoutMetrics {
  const GraphLayoutMetrics._();

  static const double nodeWidth = 260;
  static const double nodeHeaderHeight = 44;
  static const double portRowHeight = 28;
  static const double portDotSize = 12;
  static const double blockHeight = 72;
  static const double blockGap = 8;
  static const double contextPadding = 12;
}

class GraphPortLayout {
  const GraphPortLayout({
    required this.nodeId,
    required this.port,
    required this.center,
    required this.isBlock,
  });

  final String nodeId;
  final PortDefinition port;
  final Offset center;
  final bool isBlock;
}

class GraphLayoutCalculator {
  static double nodeHeight(String typeId, Map<String, dynamic> options) {
    final definition = NodeRegistry.byTypeId(typeId);
    if (definition == null) return GraphLayoutMetrics.nodeHeaderHeight;
    final portCount = definition.resolvePorts(options).length;
    return GraphLayoutMetrics.nodeHeaderHeight +
        portCount * GraphLayoutMetrics.portRowHeight +
        12;
  }

  static List<GraphPortLayout> portLayouts({
    required GraphDocument document,
    required String nodeId,
    required String typeId,
    required Map<String, dynamic> options,
    required Offset nodeTopLeft,
    bool isBlock = false,
  }) {
    final definition = NodeRegistry.byTypeId(typeId);
    if (definition == null) return const <GraphPortLayout>[];

    final ports = definition.resolvePorts(options);
    final layouts = <GraphPortLayout>[];
    var row = 0;
    for (final port in ports) {
      final y = nodeTopLeft.dy +
          GraphLayoutMetrics.nodeHeaderHeight +
          row * GraphLayoutMetrics.portRowHeight +
          GraphLayoutMetrics.portRowHeight / 2;
      final x = port.direction == PortDirection.input
          ? nodeTopLeft.dx
          : nodeTopLeft.dx + GraphLayoutMetrics.nodeWidth;
      layouts.add(
        GraphPortLayout(
          nodeId: nodeId,
          port: port,
          center: Offset(x, y),
          isBlock: isBlock,
        ),
      );
      row++;
    }
    return layouts;
  }

  static Map<String, Offset> allNodePositions(GraphDocument document) {
    final positions = <String, Offset>{};
    for (final node in document.nodes) {
      positions[node.id] = node.position.toOffset();
    }
    return positions;
  }

  static List<GraphPortLayout> allPortLayouts(GraphDocument document) {
    final layouts = <GraphPortLayout>[];
    for (final node in document.nodes) {
      layouts.addAll(
        portLayouts(
          document: document,
          nodeId: node.id,
          typeId: node.type,
          options: node.options,
          nodeTopLeft: node.position.toOffset(),
        ),
      );
    }
    for (final context in document.contexts) {
      final parent = document.nodeById(context.parentNodeId);
      if (parent == null) continue;
      var blockYOffset = nodeHeight(parent.type, parent.options) +
          GraphLayoutMetrics.contextPadding;
      for (final block in context.blocks) {
        final blockTopLeft = parent.position.toOffset().translate(
          GraphLayoutMetrics.contextPadding,
          blockYOffset,
        );
        layouts.addAll(
          portLayouts(
            document: document,
            nodeId: block.id,
            typeId: block.type,
            options: block.options,
            nodeTopLeft: blockTopLeft,
            isBlock: true,
          ),
        );
        blockYOffset += GraphLayoutMetrics.blockHeight + GraphLayoutMetrics.blockGap;
      }
    }
    return layouts;
  }

  static GraphPortLayout? findPortAt(
    GraphDocument document,
    Offset worldPoint, {
    double hitRadius = 16,
  }) {
    GraphPortLayout? closest;
    var closestDistance = double.infinity;
    for (final layout in allPortLayouts(document)) {
      final distance = (layout.center - worldPoint).distance;
      if (distance <= hitRadius && distance < closestDistance) {
        closest = layout;
        closestDistance = distance;
      }
    }
    return closest;
  }

  static Offset edgeTangent(Offset from, Offset to) {
    final delta = to - from;
    if (delta.distance < 1) return const Offset(1, 0);
    return Offset(delta.dx / delta.distance, delta.dy / delta.distance);
  }

  static Path bezierPath(Offset from, Offset to) {
    final dx = math.max(48, (to.dx - from.dx).abs() * 0.5);
    final path = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(from.dx + dx, from.dy, to.dx - dx, to.dy, to.dx, to.dy);
    return path;
  }
}

class GraphEdgePainter extends CustomPainter {
  GraphEdgePainter({
    required this.document,
    required this.selectedEdge,
    required this.pendingConnection,
    required this.colorScheme,
  });

  final GraphDocument document;
  final GraphEdge? selectedEdge;
  final PendingConnection? pendingConnection;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final portMap = <String, Map<String, Offset>>{};
    for (final layout in GraphLayoutCalculator.allPortLayouts(document)) {
      portMap.putIfAbsent(layout.nodeId, () => <String, Offset>{})[layout.port.name] =
          layout.center;
    }

    final edgePaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final selectedPaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final edge in document.edges) {
      final from = portMap[edge.fromNode]?[edge.fromPort];
      final to = portMap[edge.toNode]?[edge.toPort];
      if (from == null || to == null) continue;
      final isSelected = selectedEdge != null &&
          selectedEdge!.fromNode == edge.fromNode &&
          selectedEdge!.fromPort == edge.fromPort &&
          selectedEdge!.toNode == edge.toNode &&
          selectedEdge!.toPort == edge.toPort;
      canvas.drawPath(
        GraphLayoutCalculator.bezierPath(from, to),
        isSelected ? selectedPaint : edgePaint,
      );
    }

    final pending = pendingConnection;
    if (pending != null) {
      final start = portMap[pending.nodeId]?[pending.portName];
      if (start != null) {
        final pendingPaint = Paint()
          ..color = colorScheme.primary.withValues(alpha: 0.8)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawPath(
          GraphLayoutCalculator.bezierPath(start, pending.position),
          pendingPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GraphEdgePainter oldDelegate) {
    return oldDelegate.document != document ||
        oldDelegate.selectedEdge != selectedEdge ||
        oldDelegate.pendingConnection != pendingConnection;
  }
}

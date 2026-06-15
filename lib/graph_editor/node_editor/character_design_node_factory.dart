import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/port_type.dart';
import 'package:data_gen_ai/graph_editor/models/structural_ports.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:flutter/material.dart';
import 'package:node_editor/node_editor.dart';

typedef GraphConnectionHandler = bool Function({
  required String fromNodeId,
  required String fromPort,
  required String toNodeId,
  required String toPort,
});

abstract final class CharacterDesignNodeFactory {
  static const nodeWidth = 260.0;

  static NodeWidgetBase build(
    GraphNode node, {
    required GraphConnectionHandler onConnect,
  }) {
    final definition = NodeRegistry.byTypeId(node.type);
    final accent = definition?.accentColor ?? const Color(0xFF5C7CFA);
    final dataPorts = definition?.resolvePorts(node.options) ?? const <PortDefinition>[];
    final isBlock = definition?.isBlockNode ?? false;
    final isContext = definition?.isContextNode ?? false;

    return ContainerNodeWidget(
      name: node.id,
      typeName: node.type,
      width: nodeWidth,
      backgroundColor: const Color(0xFF1E1F22),
      radius: 8,
      border: Border.all(color: const Color(0xFF3A3D45)),
      selectedBorder: Border.all(color: accent, width: 2),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
      contentPadding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Header(
            title: definition?.displayName ?? node.type.split('.').last,
            accent: accent,
            isBlock: isBlock,
            isContext: isContext,
          ),
          if (isBlock)
            _StructuralPortRow(
              label: 'Block',
              child: InPortWidget(
                name: StructuralPorts.block,
                multiConnections: false,
                onConnect: (fromNodeId, fromPort) => onConnect(
                  fromNodeId: fromNodeId,
                  fromPort: fromPort,
                  toNodeId: node.id,
                  toPort: StructuralPorts.block,
                ),
                icon: _portIcon(accent, connected: false),
                iconConnected: _portIcon(accent, connected: true),
                connectionTheme: ConnectionTheme(color: accent, strokeWidth: 2.5),
              ),
            ),
          ...dataPorts.map((port) => _DataPortRow(
            port: port,
            nodeId: node.id,
            accent: accent,
            onConnect: onConnect,
          )),
          if (isContext)
            _StructuralPortRow(
              label: 'Blocks',
              child: OutPortWidget(
                name: StructuralPorts.blocks,
                multiConnections: true,
                icon: _portIcon(accent, connected: false, isOutput: true),
                iconConnected: _portIcon(accent, connected: true, isOutput: true),
                connectionTheme: ConnectionTheme(color: accent, strokeWidth: 2.5),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _portIcon(
    Color color, {
    required bool connected,
    bool isOutput = false,
  }) {
    return Icon(
      connected
          ? Icons.circle
          : (isOutput ? Icons.arrow_right : Icons.circle_outlined),
      color: color,
      size: 18,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.accent,
    required this.isBlock,
    required this.isContext,
  });

  final String title;
  final Color accent;
  final bool isBlock;
  final bool isContext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[accent.withValues(alpha: 0.85), accent.withValues(alpha: 0.55)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.drag_indicator, size: 16, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isContext) _Badge(label: 'Context'),
          if (isBlock) _Badge(label: 'Block'),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StructuralPortRow extends StatelessWidget {
  const _StructuralPortRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 8),
          child,
        ],
      ),
    );
  }
}

class _DataPortRow extends StatelessWidget {
  const _DataPortRow({
    required this.port,
    required this.nodeId,
    required this.accent,
    required this.onConnect,
  });

  final PortDefinition port;
  final String nodeId;
  final Color accent;
  final GraphConnectionHandler onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = ConnectionTheme(
      color: _portColor(port.type, accent),
      strokeWidth: 2,
    );
    final isInput = port.direction == PortDirection.input;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        children: <Widget>[
          if (isInput)
            InPortWidget(
              name: port.name,
              multiConnections: port.multiCapacity,
              onConnect: (fromNodeId, fromPort) => onConnect(
                fromNodeId: fromNodeId,
                fromPort: fromPort,
                toNodeId: nodeId,
                toPort: port.name,
              ),
              icon: _portDot(theme.color, connected: false),
              iconConnected: _portDot(theme.color, connected: true),
              connectionTheme: theme,
            )
          else
            const SizedBox(width: 18),
          Expanded(
            child: Text(
              port.name,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            port.type.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 10,
            ),
          ),
          if (!isInput)
            OutPortWidget(
              name: port.name,
              multiConnections: port.multiCapacity,
              icon: _portDot(theme.color, connected: false, isOutput: true),
              iconConnected: _portDot(theme.color, connected: true, isOutput: true),
              connectionTheme: theme,
            )
          else
            const SizedBox(width: 18),
        ],
      ),
    );
  }

  static Widget _portDot(Color color, {required bool connected, bool isOutput = false}) {
    return Icon(
      connected ? Icons.circle : Icons.circle_outlined,
      color: color,
      size: 16,
    );
  }

  static Color _portColor(PortType type, Color fallback) {
    return switch (type) {
      PortType.execution => const Color(0xFFFFFFFF),
      PortType.boolType => const Color(0xFFB24D4D),
      PortType.intType => const Color(0xFF4DB2B2),
      PortType.floatType => const Color(0xFF8FD14F),
      PortType.string => const Color(0xFFE87FD1),
      _ => fallback,
    };
  }
}

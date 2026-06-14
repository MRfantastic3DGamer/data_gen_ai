import 'package:data_gen_ai/graph_editor/models/graph_block.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_layout.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_port_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphNodeWidget extends StatefulWidget {
  const GraphNodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    required this.blocks,
    required this.selectedBlockId,
    required this.pendingNodeId,
    required this.pendingPortName,
    required this.onSelect,
    required this.onSelectBlock,
    required this.onAddBlock,
    required this.worldToLocal,
  });

  final GraphNode node;
  final bool isSelected;
  final List<GraphBlock> blocks;
  final String? selectedBlockId;
  final String? pendingNodeId;
  final String? pendingPortName;
  final VoidCallback onSelect;
  final void Function(String blockId) onSelectBlock;
  final void Function(String blockTypeId) onAddBlock;
  final Offset Function(Offset global) worldToLocal;

  @override
  State<GraphNodeWidget> createState() => _GraphNodeWidgetState();
}

class _GraphNodeWidgetState extends State<GraphNodeWidget> {
  Offset? _dragOrigin;
  Offset? _nodeOrigin;

  @override
  Widget build(BuildContext context) {
    final definition = NodeRegistry.byTypeId(widget.node.type);
    if (definition == null) return const SizedBox.shrink();

    final portRowHeight = GraphLayoutMetrics.portRowHeight(context);
    final ports = definition.resolvePorts(widget.node.options);
    final nodeHeight = GraphLayoutCalculator.nodeHeight(
      widget.node.type,
      widget.node.options,
      portRowHeight: portRowHeight,
    );

    return Positioned(
      left: widget.node.position.x,
      top: widget.node.position.y,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _NodeCard(
            title: definition.displayName,
            subtitle: definition.category,
            accentColor: definition.accentColor,
            isSelected: widget.isSelected,
            width: GraphLayoutMetrics.nodeWidth,
            height: nodeHeight,
            onSelect: widget.onSelect,
            onPanStart: (details) {
              widget.onSelect();
              _dragOrigin = details.globalPosition;
              _nodeOrigin = widget.node.position.toOffset();
            },
            onPanUpdate: (details) {
              if (_dragOrigin == null || _nodeOrigin == null) return;
              final delta = details.globalPosition - _dragOrigin!;
              context.read<GraphEditorCubit>().moveNode(
                widget.node.id,
                widget.node.position.copyWith(
                  x: _nodeOrigin!.dx + delta.dx,
                  y: _nodeOrigin!.dy + delta.dy,
                ),
              );
            },
            onPanEnd: (_) {
              _dragOrigin = null;
              _nodeOrigin = null;
            },
            child: Column(
              children: ports
                  .map(
                    (port) => GraphPortWidget(
                      port: port,
                      isActive:
                          widget.pendingNodeId == widget.node.id &&
                          widget.pendingPortName == port.name,
                      isPendingSource:
                          widget.pendingNodeId == widget.node.id &&
                          widget.pendingPortName == port.name,
                      onTap: () => _handlePortTap(context, port),
                      onPanStart: () => _startConnection(context, port),
                      onPanUpdate: (details) => _updateConnection(
                        context,
                        widget.worldToLocal(details.globalPosition),
                      ),
                      onPanEnd: (details) => _finishConnectionDrag(
                        context,
                        widget.worldToLocal(details.globalPosition),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (definition.isContextNode) ...<Widget>[
            const SizedBox(height: GraphLayoutMetrics.contextPadding),
            ...widget.blocks.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(
                  left: GraphLayoutMetrics.contextPadding,
                  bottom: GraphLayoutMetrics.blockGap,
                ),
                child: _BlockCard(
                  block: entry.value,
                  blockIndex: entry.key,
                  parentNode: widget.node,
                  portRowHeight: portRowHeight,
                  isSelected: widget.selectedBlockId == entry.value.id,
                  pendingNodeId: widget.pendingNodeId,
                  pendingPortName: widget.pendingPortName,
                  onSelect: () => widget.onSelectBlock(entry.value.id),
                  worldToLocal: widget.worldToLocal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: GraphLayoutMetrics.contextPadding,
              ),
              child: _AddBlockButton(
                parentTypeId: widget.node.type,
                onAdd: widget.onAddBlock,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handlePortTap(BuildContext context, PortDefinition port) {
    final cubit = context.read<GraphEditorCubit>();
    final pending = cubit.state.pendingConnection;
    final isOutput = port.direction == PortDirection.output;
    final layout = GraphLayoutCalculator.portLayouts(
      document: cubit.state.document,
      nodeId: widget.node.id,
      typeId: widget.node.type,
      options: widget.node.options,
      nodeTopLeft: widget.node.position.toOffset(),
      portRowHeight: GraphLayoutMetrics.portRowHeight(context),
    ).firstWhere((l) => l.port.name == port.name);

    if (pending == null) {
      cubit.startConnection(
        nodeId: widget.node.id,
        portName: port.name,
        isOutput: isOutput,
        position: layout.center,
      );
      return;
    }

    cubit.completeConnection(
      nodeId: widget.node.id,
      portName: port.name,
      isOutput: isOutput,
    );
  }

  void _startConnection(BuildContext context, PortDefinition port) {
    final isOutput = port.direction == PortDirection.output;
    final layout = GraphLayoutCalculator.portLayouts(
      document: context.read<GraphEditorCubit>().state.document,
      nodeId: widget.node.id,
      typeId: widget.node.type,
      options: widget.node.options,
      nodeTopLeft: widget.node.position.toOffset(),
      portRowHeight: GraphLayoutMetrics.portRowHeight(context),
    ).firstWhere((l) => l.port.name == port.name);
    context.read<GraphEditorCubit>().startConnection(
      nodeId: widget.node.id,
      portName: port.name,
      isOutput: isOutput,
      position: layout.center,
    );
  }

  void _updateConnection(BuildContext context, Offset position) {
    context.read<GraphEditorCubit>().updatePendingConnection(position);
  }

  void _finishConnectionDrag(BuildContext context, Offset position) {
    context.read<GraphEditorCubit>().tryCompleteConnectionAt(
      position,
      hitRadius: GraphLayoutMetrics.portHitRadius(context),
      portRowHeight: GraphLayoutMetrics.portRowHeight(context),
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({
    required this.block,
    required this.blockIndex,
    required this.parentNode,
    required this.portRowHeight,
    required this.isSelected,
    required this.pendingNodeId,
    required this.pendingPortName,
    required this.onSelect,
    required this.worldToLocal,
  });

  final GraphBlock block;
  final int blockIndex;
  final GraphNode parentNode;
  final double portRowHeight;
  final bool isSelected;
  final String? pendingNodeId;
  final String? pendingPortName;
  final VoidCallback onSelect;
  final Offset Function(Offset global) worldToLocal;

  Offset _blockTopLeft(BuildContext context) {
    final parentHeight = GraphLayoutCalculator.nodeHeight(
      parentNode.type,
      parentNode.options,
      portRowHeight: portRowHeight,
    );
    return parentNode.position.toOffset().translate(
      GraphLayoutMetrics.contextPadding,
      parentHeight +
          GraphLayoutMetrics.contextPadding +
          blockIndex * (_blockHeight(context) + GraphLayoutMetrics.blockGap),
    );
  }

  double _blockHeight(BuildContext context) {
    final definition = NodeRegistry.byTypeId(block.type);
    final portCount = definition?.resolvePorts(block.options).length ?? 0;
    return GraphLayoutMetrics.nodeHeaderHeight + portCount * portRowHeight + 8;
  }

  Offset _portCenter(BuildContext context, String portName) {
    final layout = GraphLayoutCalculator.portLayouts(
      document: GraphDocument.empty(),
      nodeId: block.id,
      typeId: block.type,
      options: block.options,
      nodeTopLeft: _blockTopLeft(context),
      isBlock: true,
      portRowHeight: portRowHeight,
    );
    return layout.firstWhere((l) => l.port.name == portName).center;
  }

  @override
  Widget build(BuildContext context) {
    final definition = NodeRegistry.byTypeId(block.type);
    if (definition == null) return const SizedBox.shrink();

    final ports = definition.resolvePorts(block.options);
    final blockHeight = GraphLayoutMetrics.nodeHeaderHeight +
        ports.length * portRowHeight +
        8;

    return _NodeCard(
      title: definition.displayName,
      subtitle: 'Block',
      accentColor: definition.accentColor,
      isSelected: isSelected,
      width: GraphLayoutMetrics.nodeWidth - GraphLayoutMetrics.contextPadding,
      height: blockHeight,
      onSelect: onSelect,
      child: Column(
        children: ports
            .map(
              (port) => GraphPortWidget(
                port: port,
                isActive:
                    pendingNodeId == block.id && pendingPortName == port.name,
                isPendingSource:
                    pendingNodeId == block.id && pendingPortName == port.name,
                onTap: () => _handlePortTap(context, port),
                onPanStart: () => _startConnection(context, port),
                onPanUpdate: (details) => context
                    .read<GraphEditorCubit>()
                    .updatePendingConnection(
                      worldToLocal(details.globalPosition),
                    ),
                onPanEnd: (details) => context
                    .read<GraphEditorCubit>()
                    .tryCompleteConnectionAt(
                      worldToLocal(details.globalPosition),
                      hitRadius: GraphLayoutMetrics.portHitRadius(context),
                      portRowHeight: portRowHeight,
                    ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _handlePortTap(BuildContext context, PortDefinition port) {
    final cubit = context.read<GraphEditorCubit>();
    final pending = cubit.state.pendingConnection;
    final isOutput = port.direction == PortDirection.output;

    if (pending == null) {
      cubit.startConnection(
        nodeId: block.id,
        portName: port.name,
        isOutput: isOutput,
        position: _portCenter(context, port.name),
      );
      return;
    }

    cubit.completeConnection(
      nodeId: block.id,
      portName: port.name,
      isOutput: isOutput,
    );
  }

  void _startConnection(BuildContext context, PortDefinition port) {
    final isOutput = port.direction == PortDirection.output;
    context.read<GraphEditorCubit>().startConnection(
      nodeId: block.id,
      portName: port.name,
      isOutput: isOutput,
      position: _portCenter(context, port.name),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.isSelected,
    required this.width,
    required this.height,
    required this.child,
    required this.onSelect,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final bool isSelected;
  final double width;
  final double height;
  final Widget child;
  final VoidCallback onSelect;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? accentColor : colorScheme.outlineVariant,
          width: isSelected ? 2.5 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? 0.12 : 0.08),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: onSelect,
            onPanStart: onPanStart,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            child: Container(
              height: GraphLayoutMetrics.nodeHeaderHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: isSelected ? 0.28 : 0.18),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(11),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.drag_indicator_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onSelect,
            child: SizedBox(
              height: height - GraphLayoutMetrics.nodeHeaderHeight,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBlockButton extends StatelessWidget {
  const _AddBlockButton({required this.parentTypeId, required this.onAdd});

  final String parentTypeId;
  final void Function(String blockTypeId) onAdd;

  @override
  Widget build(BuildContext context) {
    final blocks = NodeRegistry.blocksForContext(parentTypeId);
    if (blocks.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      tooltip: 'Add block',
      onSelected: onAdd,
      itemBuilder: (context) => blocks
          .map(
            (block) => PopupMenuItem<String>(
              value: block.typeId,
              child: Text(block.displayName),
            ),
          )
          .toList(),
      child: Container(
        width: GraphLayoutMetrics.nodeWidth - GraphLayoutMetrics.contextPadding,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Add block',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

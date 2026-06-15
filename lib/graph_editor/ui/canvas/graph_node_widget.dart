import 'package:data_gen_ai/graph_editor/models/graph_block.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/ui/canvas/graph_interaction_scope.dart';
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

  @override
  State<GraphNodeWidget> createState() => _GraphNodeWidgetState();
}

class _GraphNodeWidgetState extends State<GraphNodeWidget> {
  Offset? _dragOriginWorld;
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
            onHeaderPointerDown: (pointer) =>
                GraphInteractionScope.of(context).acquirePointer(pointer),
            onHeaderPointerUp: (pointer) =>
                GraphInteractionScope.of(context).releasePointer(pointer),
            onHeaderDragUpdate: (globalPosition) {
              final scope = GraphInteractionScope.of(context);
              final world = scope.globalToWorld(globalPosition);
              if (_dragOriginWorld == null || _nodeOrigin == null) {
                _dragOriginWorld = world;
                _nodeOrigin = widget.node.position.toOffset();
                widget.onSelect();
                return;
              }
              final delta = world - _dragOriginWorld!;
              context.read<GraphEditorCubit>().moveNode(
                widget.node.id,
                widget.node.position.copyWith(
                  x: _nodeOrigin!.dx + delta.dx,
                  y: _nodeOrigin!.dy + delta.dy,
                ),
              );
            },
            onHeaderDragEnd: () {
              _dragOriginWorld = null;
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
                      onDragStart: () => _startConnection(context, port),
                      onDragUpdate: (world) =>
                          _updateConnection(context, world),
                      onDragEnd: (world) =>
                          _finishConnectionDrag(context, world),
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

    if (pending == null) {
      cubit.startConnection(
        nodeId: widget.node.id,
        portName: port.name,
        isOutput: isOutput,
        position: _portCenter(context, port.name),
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
    context.read<GraphEditorCubit>().startConnection(
      nodeId: widget.node.id,
      portName: port.name,
      isOutput: isOutput,
      position: _portCenter(context, port.name),
    );
  }

  void _updateConnection(BuildContext context, Offset world) {
    context.read<GraphEditorCubit>().updatePendingConnection(world);
  }

  void _finishConnectionDrag(BuildContext context, Offset world) {
    context.read<GraphEditorCubit>().tryCompleteConnectionAt(
      world,
      hitRadius: GraphLayoutMetrics.portHitRadius(context),
      portRowHeight: GraphLayoutMetrics.portRowHeight(context),
    );
  }

  Offset _portCenter(BuildContext context, String portName) {
    final layout = GraphLayoutCalculator.portLayouts(
      document: context.read<GraphEditorCubit>().state.document,
      nodeId: widget.node.id,
      typeId: widget.node.type,
      options: widget.node.options,
      nodeTopLeft: widget.node.position.toOffset(),
      portRowHeight: GraphLayoutMetrics.portRowHeight(context),
    );
    return layout.firstWhere((l) => l.port.name == portName).center;
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
  });

  final GraphBlock block;
  final int blockIndex;
  final GraphNode parentNode;
  final double portRowHeight;
  final bool isSelected;
  final String? pendingNodeId;
  final String? pendingPortName;
  final VoidCallback onSelect;

  Offset _blockTopLeft() {
    final parentHeight = GraphLayoutCalculator.nodeHeight(
      parentNode.type,
      parentNode.options,
      portRowHeight: portRowHeight,
    );
    final blockHeight = _blockHeight();
    return parentNode.position.toOffset().translate(
      GraphLayoutMetrics.contextPadding,
      parentHeight +
          GraphLayoutMetrics.contextPadding +
          blockIndex * (blockHeight + GraphLayoutMetrics.blockGap),
    );
  }

  double _blockHeight() {
    final definition = NodeRegistry.byTypeId(block.type);
    final portCount = definition?.resolvePorts(block.options).length ?? 0;
    return GraphLayoutMetrics.nodeHeaderHeight + portCount * portRowHeight + 8;
  }

  Offset _portCenter(String portName) {
    final layout = GraphLayoutCalculator.portLayouts(
      document: GraphDocument.empty(),
      nodeId: block.id,
      typeId: block.type,
      options: block.options,
      nodeTopLeft: _blockTopLeft(),
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
    final blockHeight = _blockHeight();

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
                onDragStart: () => _startConnection(context, port),
                onDragUpdate: (world) => context
                    .read<GraphEditorCubit>()
                    .updatePendingConnection(world),
                onDragEnd: (world) => context
                    .read<GraphEditorCubit>()
                    .tryCompleteConnectionAt(
                      world,
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
        position: _portCenter(port.name),
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
      position: _portCenter(port.name),
    );
  }
}

class _NodeCard extends StatefulWidget {
  const _NodeCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.isSelected,
    required this.width,
    required this.height,
    required this.child,
    required this.onSelect,
    this.onHeaderPointerDown,
    this.onHeaderPointerUp,
    this.onHeaderDragUpdate,
    this.onHeaderDragEnd,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final bool isSelected;
  final double width;
  final double height;
  final Widget child;
  final VoidCallback onSelect;
  final void Function(int pointer)? onHeaderPointerDown;
  final void Function(int pointer)? onHeaderPointerUp;
  final void Function(Offset globalPosition)? onHeaderDragUpdate;
  final VoidCallback? onHeaderDragEnd;

  @override
  State<_NodeCard> createState() => _NodeCardState();
}

class _NodeCardState extends State<_NodeCard> {
  Offset? _bodyDownGlobal;
  Offset? _headerDownGlobal;
  var _headerDragging = false;

  static const double _tapSlop = 14;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: widget.width,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSelected ? widget.accentColor : colorScheme.outlineVariant,
          width: widget.isSelected ? 2.5 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: widget.isSelected ? 0.12 : 0.08,
            ),
            blurRadius: widget.isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              widget.onHeaderPointerDown?.call(event.pointer);
              _headerDownGlobal = event.position;
              _headerDragging = false;
            },
            onPointerMove: (event) {
              if (_headerDownGlobal == null) return;
              if (!_headerDragging &&
                  (event.position - _headerDownGlobal!).distance > _tapSlop) {
                _headerDragging = true;
              }
              if (_headerDragging) {
                widget.onHeaderDragUpdate?.call(event.position);
              }
            },
            onPointerUp: (event) {
              widget.onHeaderPointerUp?.call(event.pointer);
              if (!_headerDragging) {
                widget.onSelect();
              }
              widget.onHeaderDragEnd?.call();
              _headerDownGlobal = null;
              _headerDragging = false;
            },
            onPointerCancel: (event) {
              widget.onHeaderPointerUp?.call(event.pointer);
              widget.onHeaderDragEnd?.call();
              _headerDownGlobal = null;
              _headerDragging = false;
            },
            child: Container(
              height: GraphLayoutMetrics.nodeHeaderHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(
                  alpha: widget.isSelected ? 0.28 : 0.18,
                ),
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
                      color: widget.accentColor,
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
                          widget.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.subtitle,
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
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              GraphInteractionScope.of(context).acquirePointer(event.pointer);
              _bodyDownGlobal = event.position;
            },
            onPointerUp: (event) {
              GraphInteractionScope.of(context).releasePointer(event.pointer);
              if (_bodyDownGlobal != null &&
                  (event.position - _bodyDownGlobal!).distance < _tapSlop) {
                widget.onSelect();
              }
              _bodyDownGlobal = null;
            },
            onPointerCancel: (event) {
              GraphInteractionScope.of(context).releasePointer(event.pointer);
              _bodyDownGlobal = null;
            },
            child: SizedBox(
              height: widget.height - GraphLayoutMetrics.nodeHeaderHeight,
              child: widget.child,
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

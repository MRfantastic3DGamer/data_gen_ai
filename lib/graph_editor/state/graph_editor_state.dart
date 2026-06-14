import 'dart:ui';

import 'package:data_gen_ai/graph_editor/models/graph_block.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:equatable/equatable.dart';

class PendingConnection extends Equatable {
  const PendingConnection({
    required this.nodeId,
    required this.portName,
    required this.isOutput,
    required this.position,
  });

  final String nodeId;
  final String portName;
  final bool isOutput;
  final Offset position;

  @override
  List<Object?> get props => [nodeId, portName, isOutput, position];
}

class GraphEditorState extends Equatable {
  const GraphEditorState({
    required this.document,
    this.fileKey,
    this.isDirty = false,
    this.isSaving = false,
    this.selectedNodeId,
    this.selectedBlockId,
    this.selectedBlockParentId,
    this.pendingConnection,
    this.connectionError,
    this.viewportOffset = Offset.zero,
    this.viewportScale = 1.0,
  });

  final GraphDocument document;
  final String? fileKey;
  final bool isDirty;
  final bool isSaving;
  final String? selectedNodeId;
  final String? selectedBlockId;
  final String? selectedBlockParentId;
  final PendingConnection? pendingConnection;
  final String? connectionError;
  final Offset viewportOffset;
  final double viewportScale;

  factory GraphEditorState.initial({GraphDocument? document, String? fileKey}) {
    return GraphEditorState(
      document: document ?? GraphDocument.empty(),
      fileKey: fileKey,
    );
  }

  GraphNode? get selectedNode =>
      selectedNodeId == null ? null : document.nodeById(selectedNodeId!);

  GraphBlock? get selectedBlock {
    if (selectedBlockId == null || selectedBlockParentId == null) return null;
    final context = document.contextForNode(selectedBlockParentId!);
    if (context == null) return null;
    for (final block in context.blocks) {
      if (block.id == selectedBlockId) return block;
    }
    return null;
  }

  GraphEditorState copyWith({
    GraphDocument? document,
    String? fileKey,
    bool? isDirty,
    bool? isSaving,
    String? selectedNodeId,
    String? selectedBlockId,
    String? selectedBlockParentId,
    PendingConnection? pendingConnection,
    String? connectionError,
    Offset? viewportOffset,
    double? viewportScale,
    bool clearSelection = false,
    bool clearPendingConnection = false,
    bool clearConnectionError = false,
  }) {
    return GraphEditorState(
      document: document ?? this.document,
      fileKey: fileKey ?? this.fileKey,
      isDirty: isDirty ?? this.isDirty,
      isSaving: isSaving ?? this.isSaving,
      selectedNodeId: clearSelection
          ? null
          : (selectedNodeId ?? this.selectedNodeId),
      selectedBlockId: clearSelection
          ? null
          : (selectedBlockId ?? this.selectedBlockId),
      selectedBlockParentId: clearSelection
          ? null
          : (selectedBlockParentId ?? this.selectedBlockParentId),
      pendingConnection: clearPendingConnection
          ? null
          : (pendingConnection ?? this.pendingConnection),
      connectionError: clearConnectionError
          ? null
          : (connectionError ?? this.connectionError),
      viewportOffset: viewportOffset ?? this.viewportOffset,
      viewportScale: viewportScale ?? this.viewportScale,
    );
  }

  @override
  List<Object?> get props => [
    document,
    fileKey,
    isDirty,
    isSaving,
    selectedNodeId,
    selectedBlockId,
    selectedBlockParentId,
    pendingConnection,
    connectionError,
    viewportOffset,
    viewportScale,
  ];
}

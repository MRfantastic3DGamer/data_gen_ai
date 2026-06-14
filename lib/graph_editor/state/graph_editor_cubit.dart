import 'dart:ui';

import 'package:data_gen_ai/graph_editor/logic/graph_editor_logic.dart';
import 'package:data_gen_ai/graph_editor/models/graph_block.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/models/graph_position.dart';
import 'package:data_gen_ai/graph_editor/services/graph_file_service.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GraphEditorCubit extends Cubit<GraphEditorState> {
  GraphEditorCubit(this._fileService, {GraphDocument? document, String? fileKey})
    : super(GraphEditorState.initial(document: document, fileKey: fileKey));

  final GraphFileService _fileService;

  void load(GraphDocument document, String fileKey) {
    emit(
      GraphEditorState.initial(document: document, fileKey: fileKey),
    );
  }

  void setGraphName(String name) {
    emit(
      state.copyWith(
        document: state.document.copyWith(graphName: name),
        isDirty: true,
      ),
    );
  }

  void selectNode(String? nodeId) {
    emit(
      state.copyWith(
        selectedNodeId: nodeId,
        selectedBlockId: null,
        selectedBlockParentId: null,
        clearPendingConnection: true,
        clearConnectionError: true,
      ),
    );
  }

  void selectBlock(String parentNodeId, String blockId) {
    emit(
      state.copyWith(
        selectedNodeId: null,
        selectedBlockId: blockId,
        selectedBlockParentId: parentNodeId,
        clearPendingConnection: true,
        clearConnectionError: true,
      ),
    );
  }

  void clearSelection() {
    emit(
      state.copyWith(
        clearSelection: true,
        clearPendingConnection: true,
        clearConnectionError: true,
      ),
    );
  }

  void addNode(String typeId, GraphPosition position) {
    final node = GraphEditorLogic.createNode(typeId, position);
    final document = GraphEditorLogic.addNode(state.document, node);
    emit(
      state.copyWith(
        document: document,
        isDirty: true,
        selectedNodeId: node.id,
        selectedBlockId: null,
        selectedBlockParentId: null,
      ),
    );
  }

  void removeSelected() {
    if (state.selectedBlockId != null && state.selectedBlockParentId != null) {
      final document = GraphEditorLogic.removeBlock(
        state.document,
        state.selectedBlockParentId!,
        state.selectedBlockId!,
      );
      emit(
        state.copyWith(
          document: document,
          isDirty: true,
          clearSelection: true,
        ),
      );
      return;
    }
    if (state.selectedNodeId != null) {
      final document = GraphEditorLogic.removeNode(
        state.document,
        state.selectedNodeId!,
      );
      emit(
        state.copyWith(
          document: document,
          isDirty: true,
          clearSelection: true,
        ),
      );
    }
  }

  void moveNode(String nodeId, GraphPosition position) {
    final nodes = state.document.nodes.map((node) {
      if (node.id != nodeId) return node;
      return node.copyWith(position: position);
    }).toList();
    emit(
      state.copyWith(
        document: state.document.copyWith(nodes: nodes),
        isDirty: true,
      ),
    );
  }

  void updateNodeOptions(String nodeId, Map<String, dynamic> options) {
    final nodes = state.document.nodes.map((node) {
      if (node.id != nodeId) return node;
      return node.copyWith(options: options);
    }).toList();
    emit(
      state.copyWith(
        document: state.document.copyWith(nodes: nodes),
        isDirty: true,
      ),
    );
  }

  void updateBlockOptions(
    String parentNodeId,
    String blockId,
    Map<String, dynamic> options,
  ) {
    final contexts = state.document.contexts.map((context) {
      if (context.parentNodeId != parentNodeId) return context;
      final blocks = context.blocks.map((block) {
        if (block.id != blockId) return block;
        return block.copyWith(options: options);
      }).toList();
      return context.copyWith(blocks: blocks);
    }).toList();
    emit(
      state.copyWith(
        document: state.document.copyWith(contexts: contexts),
        isDirty: true,
      ),
    );
  }

  void addBlock(String parentNodeId, String blockTypeId) {
    final block = GraphEditorLogic.createBlock(blockTypeId);
    final document = GraphEditorLogic.addBlock(
      state.document,
      parentNodeId,
      block,
    );
    emit(
      state.copyWith(
        document: document,
        isDirty: true,
        selectedNodeId: null,
        selectedBlockId: block.id,
        selectedBlockParentId: parentNodeId,
      ),
    );
  }

  void startConnection({
    required String nodeId,
    required String portName,
    required bool isOutput,
    required Offset position,
  }) {
    emit(
      state.copyWith(
        pendingConnection: PendingConnection(
          nodeId: nodeId,
          portName: portName,
          isOutput: isOutput,
          position: position,
        ),
        clearConnectionError: true,
      ),
    );
  }

  void updatePendingConnection(Offset position) {
    final pending = state.pendingConnection;
    if (pending == null) return;
    emit(
      state.copyWith(
        pendingConnection: PendingConnection(
          nodeId: pending.nodeId,
          portName: pending.portName,
          isOutput: pending.isOutput,
          position: position,
        ),
      ),
    );
  }

  void cancelConnection() {
    emit(state.copyWith(clearPendingConnection: true, clearConnectionError: true));
  }

  void completeConnection({
    required String nodeId,
    required String portName,
    required bool isOutput,
  }) {
    final pending = state.pendingConnection;
    if (pending == null) return;

    final fromNodeId = pending.isOutput ? pending.nodeId : nodeId;
    final fromPort = pending.isOutput ? pending.portName : portName;
    final toNodeId = pending.isOutput ? nodeId : pending.nodeId;
    final toPort = pending.isOutput ? portName : pending.portName;

    final validation = GraphEditorLogic.validateConnection(
      doc: state.document,
      fromNodeId: fromNodeId,
      fromPort: fromPort,
      toNodeId: toNodeId,
      toPort: toPort,
    );

    if (!validation.isValid) {
      emit(
        state.copyWith(
          connectionError: validation.reason,
          clearPendingConnection: true,
        ),
      );
      return;
    }

    final document = GraphEditorLogic.addEdge(
      state.document,
      fromNodeId: fromNodeId,
      fromPort: fromPort,
      toNodeId: toNodeId,
      toPort: toPort,
    );
    emit(
      state.copyWith(
        document: document,
        isDirty: true,
        clearPendingConnection: true,
        clearConnectionError: true,
      ),
    );
  }

  void removeEdge(GraphEdge edge) {
    final document = GraphEditorLogic.removeEdge(state.document, edge);
    emit(state.copyWith(document: document, isDirty: true));
  }

  void setViewport(Offset offset, double scale) {
    emit(state.copyWith(viewportOffset: offset, viewportScale: scale));
  }

  Future<void> save() async {
    final key = state.fileKey;
    if (key == null) return;
    emit(state.copyWith(isSaving: true));
    await _fileService.saveGraph(key, state.document);
    emit(state.copyWith(isSaving: false, isDirty: false));
  }
}

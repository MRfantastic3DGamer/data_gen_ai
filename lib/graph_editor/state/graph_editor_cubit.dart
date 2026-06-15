import 'dart:ui';

import 'package:data_gen_ai/graph_editor/logic/graph_editor_logic.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:data_gen_ai/graph_editor/node_editor/node_editor_graph_adapter.dart';
import 'package:data_gen_ai/graph_editor/services/graph_file_service.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:node_editor/node_editor.dart';

class GraphEditorCubit extends Cubit<GraphEditorState> {
  GraphEditorCubit(this._fileService, {GraphDocument? document, String? fileKey})
    : _controller = NodeEditorController(),
      super(
        GraphEditorState.initial(
          document: document ?? GraphDocument.empty(),
          fileKey: fileKey,
        ),
      ) {
    _controller.addListener(_onControllerChanged);
    _loadIntoController(state.document);
  }

  final GraphFileService _fileService;
  final NodeEditorController _controller;
  bool _suppressControllerSync = false;

  NodeEditorController get controller => _controller;

  void attachFocusNode(FocusNode focusNode) {
    _controller.focusNode = focusNode;
  }

  void load(GraphDocument document, String fileKey) {
    final migrated = NodeEditorGraphAdapter.migrateLegacyContexts(document);
    _loadIntoController(migrated);
    emit(GraphEditorState.initial(document: migrated, fileKey: fileKey));
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
    if (nodeId == null) {
      _controller.nodesManager.unselectAllNodes();
      _controller.notify();
      emit(state.copyWith(clearSelection: true, clearConnectionError: true));
      return;
    }
    _controller.selectNodeAction(nodeId);
    emit(state.copyWith(selectedNodeId: nodeId, clearConnectionError: true));
  }

  void addNode(String typeId, Offset position) {
    _addNode(typeId, position);
  }

  String addNodeAtViewportCenter(String typeId, {bool isBlock = false}) {
    final center = NodeEditorGraphAdapter.viewportCenter(_controller);
    final count = state.document.nodes.length;
    final position = Offset(
      center.dx + (count % 4) * 28,
      center.dy + (count % 4) * 28 + (isBlock ? 48 : 0),
    );
    return _addNode(typeId, position);
  }

  void fitGraphToView() {
    NodeEditorGraphAdapter.fitToView(_controller);
  }

  String _addNode(String typeId, Offset position) {
    final graphNode = NodeEditorGraphAdapter.createGraphNode(typeId, position);
    NodeEditorGraphAdapter.addNode(
      _controller,
      graphNode,
      onConnect: _validateConnection,
    );

    final document = GraphEditorLogic.addNode(state.document, graphNode);
    emit(
      state.copyWith(
        document: document,
        isDirty: true,
        selectedNodeId: graphNode.id,
      ),
    );
    NodeEditorGraphAdapter.scrollToNode(_controller, graphNode.id);
    return graphNode.id;
  }

  void removeSelected() {
    final nodeId = state.selectedNodeId;
    if (nodeId == null) return;

    _suppressControllerSync = true;
    _controller.nodesManager.removeNode(_controller.connectionsManager, nodeId);
    _controller.notify();
    _suppressControllerSync = false;

    final document = GraphEditorLogic.removeNode(state.document, nodeId);
    emit(
      state.copyWith(
        document: document,
        isDirty: true,
        clearSelection: true,
      ),
    );
  }

  void updateNodeOptions(String nodeId, Map<String, dynamic> options) {
    final existing = state.document.nodeById(nodeId);
    if (existing == null) return;

    final updated = existing.copyWith(
      options: Map<String, dynamic>.from(options),
    );
    final nodes = state.document.nodes.map((node) {
      if (node.id != nodeId) return node;
      return updated;
    }).toList();

    final document = state.document.copyWith(nodes: nodes);
    emit(state.copyWith(document: document, isDirty: true));

    _suppressControllerSync = true;
    NodeEditorGraphAdapter.replaceNode(
      _controller,
      updated,
      onConnect: _validateConnection,
    );
    _suppressControllerSync = false;
  }

  Future<void> save() async {
    final key = state.fileKey;
    if (key == null) return;
    emit(state.copyWith(isSaving: true));
    final document = NodeEditorGraphAdapter.documentFromController(
      _controller,
      graphName: state.document.graphName,
      base: state.document,
    );
    await _fileService.saveGraph(key, document);
    emit(state.copyWith(document: document, isSaving: false, isDirty: false));
  }

  bool _validateConnection({
    required String fromNodeId,
    required String fromPort,
    required String toNodeId,
    required String toPort,
  }) {
    final validation = GraphEditorLogic.validateConnection(
      doc: state.document,
      fromNodeId: fromNodeId,
      fromPort: fromPort,
      toNodeId: toNodeId,
      toPort: toPort,
    );

    if (!validation.isValid) {
      emit(state.copyWith(connectionError: validation.reason));
      return false;
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
        clearConnectionError: true,
      ),
    );
    return true;
  }

  void _loadIntoController(GraphDocument document) {
    _suppressControllerSync = true;
    NodeEditorGraphAdapter.loadDocument(
      _controller,
      document,
      onConnect: _validateConnection,
    );
    _suppressControllerSync = false;
  }

  void _onControllerChanged() {
    if (_suppressControllerSync || isClosed) return;
    if (_controller.startPointConnection != null) return;

    final selected = _controller.selecteds.isEmpty
        ? null
        : _controller.selecteds.first;

    final document = NodeEditorGraphAdapter.documentFromController(
      _controller,
      graphName: state.document.graphName,
      base: state.document,
    );

    final nodeCountChanged = document.nodes.length != state.document.nodes.length;
    final edgeCountChanged = document.edges.length != state.document.edges.length;
    final selectionChanged = selected != state.selectedNodeId;

    if (!nodeCountChanged && !edgeCountChanged && !selectionChanged) {
      if (_positionsChanged(document)) {
        emit(state.copyWith(document: document, isDirty: true));
      }
      return;
    }

    emit(
      state.copyWith(
        document: document,
        isDirty: nodeCountChanged || edgeCountChanged ? true : state.isDirty,
        selectedNodeId: selected,
        clearSelection: selected == null,
      ),
    );
  }

  bool _positionsChanged(GraphDocument document) {
    for (final node in document.nodes) {
      final previous = state.document.nodeById(node.id);
      if (previous == null) continue;
      if (previous.position.x != node.position.x ||
          previous.position.y != node.position.y) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> close() {
    _controller.removeListener(_onControllerChanged);
    return super.close();
  }
}

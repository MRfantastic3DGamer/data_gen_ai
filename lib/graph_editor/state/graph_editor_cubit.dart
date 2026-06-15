import 'dart:ui';

import 'package:data_gen_ai/graph_editor/logic/graph_editor_logic.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node_data.dart';
import 'package:data_gen_ai/graph_editor/services/graph_file_service.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:data_gen_ai/graph_editor/vyuh/vyuh_connection_validator.dart';
import 'package:data_gen_ai/graph_editor/vyuh/vyuh_graph_adapter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

class GraphEditorCubit extends Cubit<GraphEditorState> {
  GraphEditorCubit(this._fileService, {GraphDocument? document, String? fileKey})
    : _controller = VyuhGraphAdapter.controllerFromDocument(
        document ?? GraphDocument.empty(),
      ),
      super(
        GraphEditorState.initial(
          document: document ?? GraphDocument.empty(),
          fileKey: fileKey,
        ),
      );

  final GraphFileService _fileService;
  late final NodeFlowController<GraphNodeData, dynamic> _controller;

  NodeFlowController<GraphNodeData, dynamic> get controller => _controller;

  NodeFlowEvents<GraphNodeData, dynamic> buildEvents() {
    return NodeFlowEvents<GraphNodeData, dynamic>(
      onSelectionChange: (selection) {
        final selected =
            selection.nodes.isEmpty ? null : selection.nodes.first.id;
        emit(
          state.copyWith(
            selectedNodeId: selected,
            clearConnectionError: true,
          ),
        );
      },
      connection: ConnectionEvents<GraphNodeData, dynamic>(
        onBeforeComplete: (context) {
          return VyuhConnectionValidator.validate(context, state.document);
        },
        onCreated: (connection) {
          final document = VyuhConnectionValidator.documentWithConnection(
            state.document,
            connection,
          );
          emit(state.copyWith(document: document, isDirty: true, clearConnectionError: true));
        },
        onDeleted: (connection) {
          final document = VyuhConnectionValidator.documentWithoutConnection(
            state.document,
            connection,
          );
          emit(state.copyWith(document: document, isDirty: true));
        },
      ),
      node: NodeEvents<GraphNodeData>(
        onDragStop: (node) {
          _syncDocumentFromController(markDirty: true);
        },
        onDeleted: (node) {
          final document = GraphEditorLogic.removeNode(state.document, node.id);
          emit(
            state.copyWith(
              document: document,
              isDirty: true,
              clearSelection: node.id == state.selectedNodeId,
            ),
          );
        },
      ),
    );
  }

  void load(GraphDocument document, String fileKey) {
    final migrated = VyuhGraphAdapter.migrateLegacyContexts(document);
    _controller.loadGraph(
      NodeGraph<GraphNodeData, dynamic>(
        nodes: migrated.nodes.map(VyuhGraphAdapter.vyuhNodeFromGraphNode).toList(),
        connections: migrated.edges.map(VyuhGraphAdapter.connectionFromEdge).toList(),
      ),
    );
    emit(
      GraphEditorState.initial(document: migrated, fileKey: fileKey),
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
    if (nodeId == null) {
      _controller.clearSelection();
      emit(state.copyWith(clearSelection: true, clearConnectionError: true));
      return;
    }
    _controller.selectNode(nodeId);
    emit(state.copyWith(selectedNodeId: nodeId, clearConnectionError: true));
  }

  void addNode(String typeId, Offset position) {
    final node = VyuhGraphAdapter.createVyuhNode(typeId, position);
    _controller.addNode(node);
    final document = GraphEditorLogic.addNode(
      state.document,
      node.data.toGraphNode(
        id: node.id,
        x: position.dx,
        y: position.dy,
      ),
    );
    emit(
      state.copyWith(
        document: document,
        isDirty: true,
        selectedNodeId: node.id,
      ),
    );
  }

  void removeSelected() {
    final nodeId = state.selectedNodeId;
    if (nodeId == null) return;
    _controller.removeNode(nodeId);
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
    final node = _controller.getNode(nodeId);
    if (node == null) return;

    node.data.options
      ..clear()
      ..addAll(options);
    VyuhGraphAdapter.refreshNodePorts(node);
    _controller.setNodePorts(nodeId, List<Port>.from(node.ports));
    _controller.setNodeSize(nodeId, node.size.value);

    final nodes = state.document.nodes.map((graphNode) {
      if (graphNode.id != nodeId) return graphNode;
      return graphNode.copyWith(options: Map<String, dynamic>.from(options));
    }).toList();
    emit(
      state.copyWith(
        document: state.document.copyWith(nodes: nodes),
        isDirty: true,
      ),
    );
  }

  void _syncDocumentFromController({bool markDirty = false}) {
    final document = VyuhGraphAdapter.documentFromController(
      _controller,
      graphName: state.document.graphName,
    );
    emit(
      state.copyWith(
        document: document,
        isDirty: markDirty ? true : state.isDirty,
      ),
    );
  }

  Future<void> save() async {
    final key = state.fileKey;
    if (key == null) return;
    emit(state.copyWith(isSaving: true));
    final document = VyuhGraphAdapter.documentFromController(
      _controller,
      graphName: state.document.graphName,
    );
    await _fileService.saveGraph(key, document);
    emit(state.copyWith(document: document, isSaving: false, isDirty: false));
  }

  @override
  Future<void> close() {
    _controller.dispose();
    return super.close();
  }
}

import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node.dart';
import 'package:equatable/equatable.dart';

class GraphEditorState extends Equatable {
  const GraphEditorState({
    required this.document,
    this.fileKey,
    this.isDirty = false,
    this.isSaving = false,
    this.selectedNodeId,
    this.connectionError,
  });

  final GraphDocument document;
  final String? fileKey;
  final bool isDirty;
  final bool isSaving;
  final String? selectedNodeId;
  final String? connectionError;

  factory GraphEditorState.initial({GraphDocument? document, String? fileKey}) {
    return GraphEditorState(
      document: document ?? GraphDocument.empty(),
      fileKey: fileKey,
    );
  }

  GraphNode? get selectedNode =>
      selectedNodeId == null ? null : document.nodeById(selectedNodeId!);

  GraphEditorState copyWith({
    GraphDocument? document,
    String? fileKey,
    bool? isDirty,
    bool? isSaving,
    String? selectedNodeId,
    String? connectionError,
    bool clearSelection = false,
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
      connectionError: clearConnectionError
          ? null
          : (connectionError ?? this.connectionError),
    );
  }

  @override
  List<Object?> get props => [
    document,
    fileKey,
    isDirty,
    isSaving,
    selectedNodeId,
    connectionError,
  ];
}

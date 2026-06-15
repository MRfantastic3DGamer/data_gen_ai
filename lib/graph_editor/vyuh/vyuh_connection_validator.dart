import 'package:data_gen_ai/graph_editor/logic/graph_editor_logic.dart';
import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/graph_editor/models/graph_edge.dart';
import 'package:data_gen_ai/graph_editor/models/graph_node_data.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

abstract final class VyuhConnectionValidator {
  static ConnectionValidationResult validate(
    ConnectionCompleteContext<GraphNodeData> context,
    GraphDocument document,
  ) {
    final validation = GraphEditorLogic.validateConnection(
      doc: document,
      fromNodeId: context.sourceNode.id,
      fromPort: context.sourcePort.id,
      toNodeId: context.targetNode.id,
      toPort: context.targetPort.id,
    );

    if (!validation.isValid) {
      return ConnectionValidationResult.deny(
        reason: validation.reason,
        showMessage: true,
      );
    }
    return ConnectionValidationResult.allow();
  }

  static GraphDocument documentWithConnection(
    GraphDocument document,
    Connection<dynamic> connection,
  ) {
    return GraphEditorLogic.addEdge(
      document,
      fromNodeId: connection.sourceNodeId,
      fromPort: connection.sourcePortId,
      toNodeId: connection.targetNodeId,
      toPort: connection.targetPortId,
    );
  }

  static GraphDocument documentWithoutConnection(
    GraphDocument document,
    Connection<dynamic> connection,
  ) {
    return GraphEditorLogic.removeEdge(
      document,
      GraphEdge(
        fromNode: connection.sourceNodeId,
        fromPort: connection.sourcePortId,
        toNode: connection.targetNodeId,
        toPort: connection.targetPortId,
      ),
    );
  }
}

import 'dart:convert';

import 'package:data_gen_ai/graph_editor/models/graph_document.dart';
import 'package:data_gen_ai/services/game_data_backend_service.dart';

class GraphFileInfo {
  const GraphFileInfo({required this.key, required this.graphName});

  final String key;
  final String graphName;
}

class GraphFileService {
  GraphFileService(this._backendService);

  final GameDataBackendService _backendService;

  static const graphsFolder = 'Graphs';

  String graphKey(String fileName) {
    final normalized = fileName.endsWith('.characterGraph.json')
        ? fileName
        : '$fileName.characterGraph.json';
    return '$graphsFolder/$normalized';
  }

  Future<List<GraphFileInfo>> listGraphs() async {
    final storage = _backendService.activeStorage;
    final keys = await storage.listJsonKeys();
    final graphKeys = keys.where((k) => k.startsWith('$graphsFolder/')).toList();
    final results = <GraphFileInfo>[];
    for (final key in graphKeys) {
      try {
        final content = await storage.readContent(key);
        final json = jsonDecode(content) as Map<String, dynamic>;
        results.add(
          GraphFileInfo(
            key: key,
            graphName: json['graphName'] as String? ?? key.split('/').last,
          ),
        );
      } catch (_) {
        results.add(
          GraphFileInfo(
            key: key,
            graphName: key.split('/').last,
          ),
        );
      }
    }
    results.sort((a, b) => a.graphName.compareTo(b.graphName));
    return results;
  }

  Future<GraphDocument> loadGraph(String key) async {
    final content = await _backendService.activeStorage.readContent(key);
    final json = jsonDecode(content) as Map<String, dynamic>;
    return GraphDocument.fromJson(json);
  }

  Future<void> saveGraph(String key, GraphDocument document) async {
    final encoder = const JsonEncoder.withIndent('  ');
    final content = encoder.convert(document.toJson());
    await _backendService.activeStorage.writeContent(key, content);
  }

  Future<void> deleteGraph(String key) async {
    await _backendService.activeStorage.deleteContent(key);
  }

  Future<String> createGraph(String graphName) async {
    final sanitized = graphName.trim().isEmpty ? 'NewGraph' : graphName.trim();
    final key = graphKey(sanitized);
    final document = GraphDocument.empty(graphName: sanitized);
    await saveGraph(key, document);
    return key;
  }
}

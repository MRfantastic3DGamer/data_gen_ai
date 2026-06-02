import 'package:data_gen_ai/models/ai_generation_result.dart';
import 'package:data_gen_ai/services/schema_registry.dart';
import 'package:data_gen_ai/services/gemma_service.dart';

class AIRepository {
  AIRepository(this._gemmaService);

  final GemmaService _gemmaService;

  Future<void> initialize() async {
    await _gemmaService.initialize();
    await _gemmaService.ensureModel();
  }

  Future<AIGenerationResult> generateForType({
    required String typeName,
    required String prompt,
  }) async {
    final schema = SchemaRegistry.schemaFor(typeName);
    final modelContext = SchemaRegistry.modelContextFor(typeName);
    final result = await _gemmaService.generateStructuredJson(
      typeName: typeName,
      schema: schema,
      modelContext: modelContext,
      prompt: prompt,
    );
    return _normalizeResultPayload(result);
  }

  Future<AIGenerationResult> editExisting({
    required String typeName,
    required String instruction,
    required Map<String, dynamic> currentJson,
  }) async {
    final schema = SchemaRegistry.schemaFor(typeName);
    final modelContext = SchemaRegistry.modelContextFor(typeName);
    final result = await _gemmaService.generateStructuredJson(
      typeName: typeName,
      schema: schema,
      modelContext: modelContext,
      prompt: instruction,
      currentJson: currentJson,
    );
    return _normalizeResultPayload(result);
  }

  AIGenerationResult _normalizeResultPayload(AIGenerationResult result) {
    final out = result.jsonOutput;
    Map<String, dynamic> normalized = out;

    if (out['MonoBehaviour'] is Map<String, dynamic>) {
      normalized = Map<String, dynamic>.from(
        out['MonoBehaviour'] as Map<String, dynamic>,
      );
    } else if (out['payload'] is Map<String, dynamic>) {
      normalized = Map<String, dynamic>.from(
        out['payload'] as Map<String, dynamic>,
      );
    } else if (out.containsKey('name') &&
        out['parameters'] is Map<String, dynamic>) {
      normalized = Map<String, dynamic>.from(
        out['parameters'] as Map<String, dynamic>,
      );
    }

    return AIGenerationResult(
      typeName: result.typeName,
      schemaUsed: result.schemaUsed,
      userPrompt: result.userPrompt,
      systemPrompt: result.systemPrompt,
      modelContext: result.modelContext,
      rawResponse: result.rawResponse,
      jsonOutput: normalized,
      traceLogs: result.traceLogs,
      usedTools: result.usedTools,
    );
  }
}

class AIGenerationResult {
  const AIGenerationResult({
    required this.typeName,
    required this.schemaUsed,
    required this.userPrompt,
    required this.systemPrompt,
    required this.modelContext,
    required this.rawResponse,
    required this.jsonOutput,
    required this.traceLogs,
    required this.usedTools,
  });

  final String typeName;
  final String schemaUsed;
  final String userPrompt;
  final String systemPrompt;
  final String modelContext;
  final String rawResponse;
  final Map<String, dynamic> jsonOutput;
  final List<String> traceLogs;
  final bool usedTools;
}

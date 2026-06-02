class AIParseException implements Exception {
  const AIParseException({
    required this.message,
    required this.rawResponse,
    this.systemPrompt,
    this.schemaUsed,
    this.modelContext,
    this.traceLogs = const <String>[],
    this.usedTools = false,
  });

  final String message;
  final String rawResponse;
  final String? systemPrompt;
  final String? schemaUsed;
  final String? modelContext;
  final List<String> traceLogs;
  final bool usedTools;

  @override
  String toString() => 'AIParseException: $message';
}

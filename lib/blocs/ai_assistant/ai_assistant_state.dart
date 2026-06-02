import 'package:equatable/equatable.dart';

class AIAssistantState extends Equatable {
  const AIAssistantState({
    this.initializing = false,
    this.ready = false,
    this.loading = false,
    this.output,
    this.rawResponse,
    this.systemPrompt,
    this.schemaUsed,
    this.modelContext,
    this.usedTools = false,
    this.traceLogs = const <String>[],
    this.lastTypeName,
    this.lastPrompt,
    this.lastInputJson,
    this.error,
    this.history = const <String>[],
  });

  final bool initializing;
  final bool ready;
  final bool loading;
  final Map<String, dynamic>? output;
  final String? rawResponse;
  final String? systemPrompt;
  final String? schemaUsed;
  final String? modelContext;
  final bool usedTools;
  final List<String> traceLogs;
  final String? lastTypeName;
  final String? lastPrompt;
  final Map<String, dynamic>? lastInputJson;
  final String? error;
  final List<String> history;

  AIAssistantState copyWith({
    bool? initializing,
    bool? ready,
    bool? loading,
    Map<String, dynamic>? output,
    String? rawResponse,
    String? systemPrompt,
    String? schemaUsed,
    String? modelContext,
    bool? usedTools,
    List<String>? traceLogs,
    String? lastTypeName,
    String? lastPrompt,
    Map<String, dynamic>? lastInputJson,
    String? error,
    List<String>? history,
  }) {
    return AIAssistantState(
      initializing: initializing ?? this.initializing,
      ready: ready ?? this.ready,
      loading: loading ?? this.loading,
      output: output ?? this.output,
      rawResponse: rawResponse ?? this.rawResponse,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      schemaUsed: schemaUsed ?? this.schemaUsed,
      modelContext: modelContext ?? this.modelContext,
      usedTools: usedTools ?? this.usedTools,
      traceLogs: traceLogs ?? this.traceLogs,
      lastTypeName: lastTypeName ?? this.lastTypeName,
      lastPrompt: lastPrompt ?? this.lastPrompt,
      lastInputJson: lastInputJson ?? this.lastInputJson,
      error: error,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    initializing,
    ready,
    loading,
    output,
    rawResponse,
    systemPrompt,
    schemaUsed,
    modelContext,
    usedTools,
    traceLogs,
    lastTypeName,
    lastPrompt,
    lastInputJson,
    error,
    history,
  ];
}

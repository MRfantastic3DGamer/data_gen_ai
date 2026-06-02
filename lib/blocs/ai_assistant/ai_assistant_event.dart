import 'package:equatable/equatable.dart';

sealed class AIAssistantEvent extends Equatable {
  const AIAssistantEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class AIAssistantInitialized extends AIAssistantEvent {
  const AIAssistantInitialized();
}

class AIGenerateRequested extends AIAssistantEvent {
  const AIGenerateRequested({required this.typeName, required this.prompt});

  final String typeName;
  final String prompt;

  @override
  List<Object?> get props => <Object?>[typeName, prompt];
}

class AIEditRequested extends AIAssistantEvent {
  const AIEditRequested({
    required this.typeName,
    required this.prompt,
    required this.currentJson,
  });

  final String typeName;
  final String prompt;
  final Map<String, dynamic> currentJson;

  @override
  List<Object?> get props => <Object?>[typeName, prompt, currentJson];
}

import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_event.dart';
import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_state.dart';
import 'package:data_gen_ai/models/ai_parse_exception.dart';
import 'package:data_gen_ai/repositories/ai_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AIAssistantBloc extends Bloc<AIAssistantEvent, AIAssistantState> {
  AIAssistantBloc(this._aiRepository) : super(const AIAssistantState()) {
    on<AIAssistantInitialized>(_onInitialized);
    on<AIGenerateRequested>(_onGenerateRequested);
    on<AIEditRequested>(_onEditRequested);
  }

  final AIRepository _aiRepository;

  Future<void> _onInitialized(
    AIAssistantInitialized event,
    Emitter<AIAssistantState> emit,
  ) async {
    emit(state.copyWith(initializing: true));
    try {
      await _aiRepository.initialize();
      emit(state.copyWith(initializing: false, ready: true));
    } catch (e) {
      emit(state.copyWith(initializing: false, error: e.toString()));
    }
  }

  Future<void> _onGenerateRequested(
    AIGenerateRequested event,
    Emitter<AIAssistantState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        lastTypeName: event.typeName,
        lastPrompt: event.prompt,
        lastInputJson: null,
      ),
    );
    try {
      final result = await _aiRepository.generateForType(
        typeName: event.typeName,
        prompt: event.prompt,
      );
      emit(
        state.copyWith(
          loading: false,
          output: result.jsonOutput,
          rawResponse: result.rawResponse,
          schemaUsed: result.schemaUsed,
          modelContext: result.modelContext,
          systemPrompt: result.systemPrompt,
          usedTools: result.usedTools,
          traceLogs: result.traceLogs,
          history: <String>[
            ...state.history,
            'Generate ${event.typeName}: ${event.prompt}',
          ],
        ),
      );
    } on AIParseException catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.message,
          rawResponse: e.rawResponse,
          systemPrompt: e.systemPrompt,
          schemaUsed: e.schemaUsed,
          modelContext: e.modelContext,
          usedTools: e.usedTools,
          traceLogs: e.traceLogs,
          history: <String>[
            ...state.history,
            'Generate ${event.typeName} failed: ${e.message}',
          ],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
          history: <String>[
            ...state.history,
            'Generate ${event.typeName} failed: $e',
          ],
        ),
      );
    }
  }

  Future<void> _onEditRequested(
    AIEditRequested event,
    Emitter<AIAssistantState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        lastTypeName: event.typeName,
        lastPrompt: event.prompt,
        lastInputJson: event.currentJson,
      ),
    );
    try {
      final result = await _aiRepository.editExisting(
        typeName: event.typeName,
        instruction: event.prompt,
        currentJson: event.currentJson,
      );
      emit(
        state.copyWith(
          loading: false,
          output: result.jsonOutput,
          rawResponse: result.rawResponse,
          schemaUsed: result.schemaUsed,
          modelContext: result.modelContext,
          systemPrompt: result.systemPrompt,
          usedTools: result.usedTools,
          traceLogs: result.traceLogs,
          history: <String>[
            ...state.history,
            'Edit ${event.typeName}: ${event.prompt}',
          ],
        ),
      );
    } on AIParseException catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.message,
          rawResponse: e.rawResponse,
          systemPrompt: e.systemPrompt,
          schemaUsed: e.schemaUsed,
          modelContext: e.modelContext,
          usedTools: e.usedTools,
          traceLogs: e.traceLogs,
          history: <String>[
            ...state.history,
            'Edit ${event.typeName} failed: ${e.message}',
          ],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
          history: <String>[
            ...state.history,
            'Edit ${event.typeName} failed: $e',
          ],
        ),
      );
    }
  }
}

import 'dart:convert';

import 'package:data_gen_ai/core/constants.dart';
import 'package:data_gen_ai/models/ai_generation_result.dart';
import 'package:data_gen_ai/models/ai_parse_exception.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaService {
  InferenceModel? _model;
  InferenceChat? _chat;
  final List<String> _lastTraceLogs = <String>[];

  static const String _toolGetSchema = 'get_schema';
  static const String _toolValidateJson = 'validate_json';

  Future<void> initialize() async {
    await FlutterGemma.initialize();
  }

  Future<void> ensureModel() async {
    await FlutterGemma.installModel(
      modelType: ModelType.gemmaIt,
    ).fromNetwork(AppConstants.modelUrl).install();
    _model = await FlutterGemma.getActiveModel(
      maxTokens: 4096,
      preferredBackend: PreferredBackend.gpu,
    );
    _chat = await _createChatWithTools();
  }

  Future<InferenceChat> _createChatWithTools() async {
    return _model!.createChat(
      supportsFunctionCalls: true,
      tools: const <Tool>[
        Tool(
          name: _toolGetSchema,
          description:
              'Returns the exact JSON schema for a ScriptableObject type.',
          parameters: <String, dynamic>{
            'type': 'object',
            'properties': <String, dynamic>{
              'typeName': <String, dynamic>{
                'type': 'string',
                'description': 'Unity ScriptableObject type name',
              },
            },
            'required': <String>['typeName'],
          },
        ),
        Tool(
          name: _toolValidateJson,
          description:
              'Validates generated JSON payload against required root shape.',
          parameters: <String, dynamic>{
            'type': 'object',
            'properties': <String, dynamic>{
              'typeName': <String, dynamic>{'type': 'string'},
              'json': <String, dynamic>{'type': 'object'},
            },
            'required': <String>['typeName', 'json'],
          },
        ),
      ],
      toolChoice: ToolChoice.auto,
      modelType: ModelType.gemmaIt,
    );
  }

  Future<AIGenerationResult> generateStructuredJson({
    required String typeName,
    required String schema,
    required String modelContext,
    required String prompt,
    Map<String, dynamic>? currentJson,
  }) async {
    _lastTraceLogs.clear();
    _chat ??= await _createChatWithTools();
    if (_chat == null) {
      throw StateError('Model is not ready. Call ensureModel() first.');
    }

    final systemPrompt = StringBuffer()
      ..writeln('You are a strict Unity ScriptableObject JSON generator.')
      ..writeln('Target type: $typeName')
      ..writeln('You must follow this schema exactly.')
      ..writeln('Use numeric enum values where enums are requested.')
      ..writeln(
        'Keep GUID references in the format {"guid":"...","fileID":123,"type":2}.',
      )
      ..writeln(
        'Return ONLY the raw JSON object matching the schema below. '
        'Do NOT wrap it in a function call, do NOT add any prose or '
        'markdown around it.',
      )
      ..writeln('Schema:')
      ..writeln(schema)
      ..writeln('')
      ..writeln('Related model context:')
      ..writeln(modelContext);

    if (currentJson != null) {
      systemPrompt.writeln('Current JSON to edit: ${jsonEncode(currentJson)}');
    }

    final userPrompt = 'User request: $prompt';

    _lastTraceLogs.add('Schema loaded for $typeName (${schema.length} chars)');
    _lastTraceLogs.add('Model context loaded (${modelContext.length} chars)');
    _lastTraceLogs.add('System prompt prepared');
    _lastTraceLogs.add('User prompt: $prompt');
    if (currentJson != null) {
      _lastTraceLogs.add(
        'Input JSON attached (${jsonEncode(currentJson).length} chars)',
      );
    }

    await _chat!.addQueryChunk(
      Message(text: '${systemPrompt.toString()}\n$userPrompt', isUser: true),
    );

    bool usedTools = false;
    String rawResponse = '';

    for (int round = 0; round < 5; round++) {
      final response = await _chat!.generateChatResponse();
      if (response is TextResponse) {
        rawResponse = response.token;
        _lastTraceLogs.add(
          'Round ${round + 1}: text response received (${rawResponse.length} chars)',
        );
        break;
      }

      if (response is FunctionCallResponse) {
        usedTools = true;
        final toolPayload = _executeToolCall(typeName, schema, response);
        _lastTraceLogs.add(
          'Round ${round + 1}: tool ${response.name} executed',
        );
        await _chat!.addQueryChunk(
          Message.toolResponse(toolName: response.name, response: toolPayload),
        );
        continue;
      }

      if (response is ParallelFunctionCallResponse) {
        usedTools = true;
        for (final call in response.calls) {
          final toolPayload = _executeToolCall(typeName, schema, call);
          _lastTraceLogs.add(
            'Round ${round + 1}: parallel tool ${call.name} executed',
          );
          await _chat!.addQueryChunk(
            Message.toolResponse(toolName: call.name, response: toolPayload),
          );
        }
      }
    }

    if (rawResponse.trim().isEmpty) {
      throw AIParseException(
        message: 'Model did not return a final JSON text response.',
        rawResponse: '',
        systemPrompt: systemPrompt.toString(),
        schemaUsed: schema,
        modelContext: modelContext,
        traceLogs: List<String>.from(_lastTraceLogs),
        usedTools: usedTools,
      );
    }

    final Map<String, dynamic> jsonOutput;
    try {
      jsonOutput = _extractJson(rawResponse);
      _lastTraceLogs.add('Final JSON extracted successfully');
    } on FormatException catch (e) {
      _lastTraceLogs.add('JSON parse failed: $e');
      throw AIParseException(
        message: 'FormatException: ${e.message} for output.',
        rawResponse: rawResponse,
        systemPrompt: systemPrompt.toString(),
        schemaUsed: schema,
        modelContext: modelContext,
        traceLogs: List<String>.from(_lastTraceLogs),
        usedTools: usedTools,
      );
    }

    return AIGenerationResult(
      typeName: typeName,
      schemaUsed: schema,
      userPrompt: prompt,
      systemPrompt: systemPrompt.toString(),
      modelContext: modelContext,
      rawResponse: rawResponse,
      jsonOutput: jsonOutput,
      traceLogs: List<String>.from(_lastTraceLogs),
      usedTools: usedTools,
    );
  }

  Map<String, dynamic> _extractJson(String text) {
    var cleaned = text;

    // Strip markdown code fences the model sometimes wraps output in
    cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw FormatException(
        'AI response did not contain valid JSON object.',
        text,
      );
    }
    var jsonString = cleaned.substring(start, end + 1);

    // --- Repair pass: fix common LLM JSON defects ---

    // 1. Fix rogue trailing quote on numbers: `1.0"` → `1.0`
    //    Matches a digit (possibly with decimal) followed by " then a
    //    structural char (comma, brace, bracket). Avoids touching real strings.
    jsonString = jsonString.replaceAllMapped(
      RegExp(r'(\d+\.?\d*)"(\s*[,}\]])'),
      (m) => '${m[1]}${m[2]}',
    );

    // 2. Remove trailing commas before closing brackets/braces
    jsonString = jsonString.replaceAll(RegExp(r',\s*([}\]])'), r'$1');

    // 3. Context-aware bracket repair: fix wrong bracket types and close
    //    unclosed pairs (e.g. model writes } where ] should be).
    jsonString = _repairBrackets(jsonString);

    // First attempt with repairs applied
    try {
      return _unwrapFunctionCall(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } on FormatException {
      // intentional fallthrough – try original extraction as last resort
    }

    // Last resort: original slice without repairs
    final rawSlice = cleaned.substring(start, end + 1);
    return _unwrapFunctionCall(
      jsonDecode(rawSlice) as Map<String, dynamic>,
    );
  }

  /// Stack-based bracket repair: when a closing bracket doesn't match
  /// the most recent opening bracket on the stack, replace it with the
  /// correct one. Then append any unclosed pairs at the end.
  String _repairBrackets(String json) {
    final stack = <String>[];
    final chars = json.split('');
    bool inString = false;
    bool escaped = false;

    for (int i = 0; i < chars.length; i++) {
      final c = chars[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (c == r'\') {
        escaped = true;
        continue;
      }
      if (c == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      switch (c) {
        case '{':
          stack.add('{');
        case '[':
          stack.add('[');
        case '}':
          if (stack.isNotEmpty && stack.last == '[') {
            chars[i] = ']';
            stack.removeLast();
          } else if (stack.isNotEmpty && stack.last == '{') {
            stack.removeLast();
          }
        case ']':
          if (stack.isNotEmpty && stack.last == '{') {
            chars[i] = '}';
            stack.removeLast();
          } else if (stack.isNotEmpty && stack.last == '[') {
            stack.removeLast();
          }
      }
    }

    final buf = StringBuffer(chars.join());
    for (int i = stack.length - 1; i >= 0; i--) {
      buf.write(stack[i] == '{' ? '}' : ']');
    }
    return buf.toString();
  }

  /// When Gemma wraps its output in a hallucinated function call
  /// like {"name":"...", "parameters": {...}}, extract the inner payload.
  Map<String, dynamic> _unwrapFunctionCall(Map<String, dynamic> json) {
    if (json.containsKey('name') &&
        json.containsKey('parameters') &&
        json['parameters'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(
        json['parameters'] as Map<String, dynamic>,
      );
    }
    return json;
  }

  Map<String, dynamic> _executeToolCall(
    String typeName,
    String schema,
    FunctionCallResponse call,
  ) {
    switch (call.name) {
      case _toolGetSchema:
        return <String, dynamic>{
          'typeName': call.args['typeName'] ?? typeName,
          'schema': schema,
        };
      case _toolValidateJson:
        final payload = call.args['json'];
        final isValid = payload is Map<String, dynamic>;
        return <String, dynamic>{
          'valid': isValid,
          'errors': isValid
              ? <String>[]
              : <String>[
                  'Expected top-level JSON object for generated payload.',
                ],
        };
      default:
        return <String, dynamic>{
          'valid': false,
          'errors': <String>['Unknown tool: ${call.name}'],
        };
    }
  }

  Future<void> dispose() async {
    _chat?.close();
    _chat = null;
  }
}

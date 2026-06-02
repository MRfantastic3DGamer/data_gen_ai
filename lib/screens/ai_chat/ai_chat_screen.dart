import 'dart:convert';

import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_bloc.dart';
import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_event.dart';
import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_state.dart';
import 'package:data_gen_ai/blocs/item/item_bloc.dart';
import 'package:data_gen_ai/blocs/item/item_event.dart';
import 'package:data_gen_ai/models/item_data.dart';
import 'package:data_gen_ai/blocs/character/character_bloc.dart';
import 'package:data_gen_ai/blocs/character/character_event.dart';
import 'package:data_gen_ai/models/character_data.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/widgets/common/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedType = 'CharacterData';

  static const List<String> _supportedTypes = <String>[
    'CharacterData',
    'ItemData',
    'BeliefSO',
    'ActionableSO',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Workspace')),
      body: BlocBuilder<AIAssistantBloc, AIAssistantState>(
        builder: (context, state) {
          if (state.initializing) {
            return const LoadingIndicator(
              label: 'Preparing local Gemma model...',
            );
          }
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Row(
                  children: <Widget>[
                    const Text('Target Type:'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _supportedTypes
                            .map(
                              (type) => DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: <Widget>[
                    Card(
                      child: ListTile(
                        leading: Icon(
                          state.usedTools
                              ? Icons.build_circle_outlined
                              : Icons.build_outlined,
                        ),
                        title: Text(
                          state.usedTools
                              ? 'Tool calls were used by Gemma'
                              : 'No tool calls used in last run',
                        ),
                        subtitle: Text(
                          state.schemaUsed == null
                              ? 'Schema not loaded yet'
                              : 'Schema chars: ${state.schemaUsed!.length}',
                        ),
                      ),
                    ),
                    for (final history in state.history)
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(history),
                      ),
                    if (state.output != null) ...<Widget>[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            const JsonEncoder.withIndent(
                              '  ',
                            ).convert(state.output),
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: FilledButton.icon(
                                icon: const Icon(Icons.save_alt),
                                label: const Text('Save as New'),
                                onPressed: () => _saveGenerated(
                                  context,
                                  state,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.edit_note),
                                label: const Text('Open in Editor'),
                                onPressed: () => _openInEditor(
                                  context,
                                  state,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (state.traceLogs.isNotEmpty)
                      Card(
                        child: ExpansionTile(
                          title: const Text('Generation Trace'),
                          subtitle: const Text(
                            'Prompt, schema, tools, parser steps',
                          ),
                          children: <Widget>[
                            for (final log in state.traceLogs)
                              ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                title: Text(log),
                              ),
                          ],
                        ),
                      ),
                    if (state.systemPrompt != null)
                      Card(
                        child: ExpansionTile(
                          title: const Text('Exact System Prompt Sent'),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: SelectableText(
                                state.systemPrompt!,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (state.schemaUsed != null)
                      Card(
                        child: ExpansionTile(
                          title: const Text('Exact Schema Used'),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: SelectableText(
                                state.schemaUsed!,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (state.rawResponse != null)
                      Card(
                        child: ExpansionTile(
                          title: const Text('Raw Model Response'),
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: SelectableText(
                                state.rawResponse!,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (state.error != null)
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Parse Error',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                state.error!,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText:
                              'Prompt (e.g. create carnivore hunter character)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: state.loading
                          ? null
                          : () {
                              final prompt = _controller.text.trim();
                              if (prompt.isEmpty) return;
                              context.read<AIAssistantBloc>().add(
                                AIGenerateRequested(
                                  typeName: _selectedType,
                                  prompt: prompt,
                                ),
                              );
                            },
                      child: state.loading
                          ? const Text('...')
                          : const Text('Generate'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _deriveObjectName(Map<String, dynamic> output, String typeName) {
    final candidates = <String>[
      if (output['ItemId'] is String) output['ItemId'] as String,
      if (output['m_Name'] is String) output['m_Name'] as String,
      if (output['Name'] is String) output['Name'] as String,
      if (output['name'] is String) output['name'] as String,
    ];
    for (final c in candidates) {
      if (c.trim().isNotEmpty) return c.trim();
    }
    return '${typeName}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _saveGenerated(
    BuildContext context,
    AIAssistantState state,
  ) async {
    final output = state.output;
    final typeName = state.lastTypeName;
    if (output == null || typeName == null) return;

    final suggested = _deriveObjectName(output, typeName);
    final nameController = TextEditingController(text: suggested);

    final confirmedName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save as New'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'File name (without .json)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(nameController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmedName == null || confirmedName.isEmpty) return;
    if (!context.mounted) return;

    try {
      final repo = context.read<ProjectRepository>();
      final path = await repo.createNewFile(
        typeName: typeName,
        objectName: confirmedName,
        payload: output,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to $path')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  void _openInEditor(BuildContext context, AIAssistantState state) {
    final output = state.output;
    final typeName = state.lastTypeName;
    if (output == null || typeName == null) return;

    switch (typeName) {
      case 'ItemData':
        try {
          final item = ItemDataModel.fromJson(output);
          context.read<ItemBloc>().add(ItemUpdated(item));
        } catch (_) {}
        context.push('/items/edit');
      case 'CharacterData':
        try {
          final character = CharacterDataModel.fromJson(output);
          context.read<CharacterBloc>().add(CharacterUpdated(character));
        } catch (_) {}
        context.push('/characters/edit');
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No dedicated editor for $typeName yet'),
          ),
        );
    }
  }
}

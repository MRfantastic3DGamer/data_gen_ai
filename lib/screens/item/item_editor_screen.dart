import 'dart:convert';

import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_bloc.dart';
import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_event.dart';
import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_state.dart';
import 'package:data_gen_ai/blocs/item/item_bloc.dart';
import 'package:data_gen_ai/blocs/item/item_event.dart';
import 'package:data_gen_ai/blocs/item/item_state.dart';
import 'package:data_gen_ai/models/item_data.dart';
import 'package:data_gen_ai/widgets/common/ai_prompt_sheet.dart';
import 'package:data_gen_ai/widgets/common/json_preview_panel.dart';
import 'package:data_gen_ai/widgets/editors/item_data_editor_form.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ItemEditorScreen extends StatefulWidget {
  const ItemEditorScreen({super.key});

  @override
  State<ItemEditorScreen> createState() => _ItemEditorScreenState();
}

class _ItemEditorScreenState extends State<ItemEditorScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).extra as String?;
    if (path != null) {
      context.read<ItemBloc>().add(ItemLoaded(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AIAssistantBloc, AIAssistantState>(
      listenWhen: (previous, current) =>
          previous.output != current.output &&
          current.output != null &&
          current.lastTypeName == 'ItemData',
      listener: (context, state) {
        final output = state.output!;
        try {
          final nextItem = ItemDataModel.fromJson(output);
          context.read<ItemBloc>().add(ItemUpdated(nextItem));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AI output applied to Item form')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI output could not populate form: $e')),
          );
        }

        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('AI Generated JSON'),
            content: SingleChildScrollView(
              child: SelectableText(
                const JsonEncoder.withIndent('  ').convert(state.output),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Item Editor'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: () => _openAI(context),
            ),
          ],
        ),
        body: BlocConsumer<ItemBloc, ItemState>(
          listener: (context, state) {
            _idController.text = state.data.itemId;
            _descriptionController.text = state.data.description;
            if (state.saved) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Item saved')));
            }
          },
          builder: (context, state) {
            final data = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  BlocBuilder<AIAssistantBloc, AIAssistantState>(
                    buildWhen: (previous, current) =>
                        previous.loading != current.loading ||
                        previous.error != current.error ||
                        previous.traceLogs != current.traceLogs ||
                        previous.lastPrompt != current.lastPrompt ||
                        previous.rawResponse != current.rawResponse ||
                        previous.output != current.output ||
                        previous.modelContext != current.modelContext ||
                        previous.schemaUsed != current.schemaUsed ||
                        previous.lastTypeName != current.lastTypeName,
                    builder: (context, aiState) {
                      if (aiState.lastTypeName != 'ItemData') {
                        return const SizedBox.shrink();
                      }
                      return SectionCard(
                        title: 'AI Activity',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Status: ${aiState.loading ? 'Generating...' : 'Idle'}',
                            ),
                            if (aiState.lastPrompt != null)
                              Text('Last prompt: ${aiState.lastPrompt}'),
                            if (aiState.error != null)
                              Text(
                                'Error: ${aiState.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            if (aiState.output != null) ...<Widget>[
                              const SizedBox(height: 8),
                              const Text('AI Output (parsed JSON):'),
                              SizedBox(
                                height: 140,
                                child: JsonPreviewPanel(json: aiState.output!),
                              ),
                            ],
                            if (aiState.rawResponse != null) ...<Widget>[
                              const SizedBox(height: 8),
                              const Text('Raw response:'),
                              SelectableText(
                                aiState.rawResponse!,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ],
                            if (aiState.schemaUsed != null) ...<Widget>[
                              const SizedBox(height: 8),
                              const Text('Schema used:'),
                              SelectableText(
                                aiState.schemaUsed!,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ],
                            if (aiState.modelContext != null) ...<Widget>[
                              const SizedBox(height: 8),
                              const Text('Injected model context:'),
                              SelectableText(
                                aiState.modelContext!,
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ],
                            if (aiState.traceLogs.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 8),
                              const Text('Trace logs:'),
                              for (final log in aiState.traceLogs)
                                Text(
                                  '- $log',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  ItemDataEditorForm(
                    data: data,
                    idController: _idController,
                    descriptionController: _descriptionController,
                    onChanged: (next) =>
                        context.read<ItemBloc>().add(ItemUpdated(next)),
                  ),
                  SectionCard(
                    title: 'JSON Preview',
                    child: SizedBox(
                      height: 280,
                      child: JsonPreviewPanel(json: data.toJson()),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _save(context),
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final itemBloc = context.read<ItemBloc>();
    final existingPath =
        GoRouterState.of(context).extra as String? ?? itemBloc.state.path;

    if (existingPath != null && existingPath.isNotEmpty) {
      itemBloc.add(ItemSaved(existingPath));
      return;
    }

    final data = itemBloc.state.data;
    final suggested =
        data.itemId.isNotEmpty ? data.itemId : 'NewItem';
    final nameController = TextEditingController(text: suggested);

    final confirmedName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save New Item'),
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
    itemBloc.add(ItemSavedNew(confirmedName));
  }

  void _openAI(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AIPromptSheet(
        title: 'AI Item Assist',
        onSubmit: (prompt) {
          final payload = context.read<ItemBloc>().state.data.toJson();
          context.read<AIAssistantBloc>().add(
            AIEditRequested(
              typeName: 'ItemData',
              prompt: prompt,
              currentJson: payload,
            ),
          );
        },
      ),
    );
  }
}

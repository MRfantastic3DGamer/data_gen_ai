import 'dart:convert';

import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_bloc.dart';
import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_event.dart';
import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_state.dart';
import 'package:data_gen_ai/blocs/character/character_bloc.dart';
import 'package:data_gen_ai/blocs/character/character_event.dart';
import 'package:data_gen_ai/blocs/character/character_state.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/core/game_data_path.dart';
import 'package:data_gen_ai/widgets/common/ai_prompt_sheet.dart';
import 'package:data_gen_ai/widgets/common/json_preview_panel.dart';
import 'package:data_gen_ai/widgets/editors/character_data_editor_form.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/visualization/belief_chain_diagram.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CharacterEditorScreen extends StatefulWidget {
  const CharacterEditorScreen({super.key});

  @override
  State<CharacterEditorScreen> createState() => _CharacterEditorScreenState();
}

class _CharacterEditorScreenState extends State<CharacterEditorScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  String? _loadedPath;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).extra as String?;
    if (path != _loadedPath) {
      _loadedPath = path;
      if (path != null) {
        context.read<CharacterBloc>().add(CharacterLoaded(path));
        _fileNameController.text = _fileNameFromPath(path);
      } else {
        _fileNameController.clear();
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  static String _fileNameFromPath(String path) {
    final file = GameDataPath.fileNameFromKey(path);
    return file.endsWith('.json') ? file.substring(0, file.length - 5) : file;
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).extra as String?;
    final isNew = path == null;

    return BlocListener<AIAssistantBloc, AIAssistantState>(
      listenWhen: (previous, current) =>
          previous.output != current.output && current.output != null,
      listener: (context, state) {
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
          title: Text(isNew ? 'New character' : 'Character editor'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: () => _openAI(context),
            ),
          ],
        ),
        body: BlocConsumer<CharacterBloc, CharacterState>(
          listener: (context, state) {
            _descriptionController.text = state.data.description;
            if (state.saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isNew && state.path != null
                        ? 'Saved as ${state.path}'
                        : 'Character saved',
                  ),
                ),
              );
              context.read<GameDataBloc>().add(const GameDataReloadRequested());
              if (isNew && state.path != null) {
                context.pop(state.path);
              }
            }
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = state.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  SectionCard(
                    title: 'File',
                    child: TextField(
                      controller: _fileNameController,
                      decoration: const InputDecoration(
                        labelText: 'File name',
                        helperText: 'Saved as Characters/{name}.json',
                      ),
                      textCapitalization: TextCapitalization.none,
                      readOnly: !isNew,
                    ),
                  ),
                  CharacterDataEditorForm(
                    data: data,
                    descriptionController: _descriptionController,
                    onChanged: (next) => context.read<CharacterBloc>().add(
                      CharacterUpdated(next),
                    ),
                  ),
                  BeliefChainDiagram(
                    beliefCount: data.beliefsObjects.length,
                    actionableCount: data.actionables.length,
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
          onPressed: () {
            context.read<CharacterBloc>().add(
              CharacterSaved(
                path: path ?? context.read<CharacterBloc>().state.path,
                fileName: _fileNameController.text,
              ),
            );
          },
          icon: const Icon(Icons.save),
          label: const Text('Save'),
        ),
      ),
    );
  }

  void _openAI(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AIPromptSheet(
        title: 'AI Character Assist',
        onSubmit: (prompt) {
          final payload = context.read<CharacterBloc>().state.data.toJson();
          context.read<AIAssistantBloc>().add(
            AIEditRequested(
              typeName: 'CharacterData',
              prompt: prompt,
              currentJson: payload,
            ),
          );
        },
      ),
    );
  }
}

import 'dart:convert';

import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_bloc.dart';
import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_event.dart';
import 'package:data_gen_ai/blocs/ai_assistant/ai_assistant_state.dart';
import 'package:data_gen_ai/blocs/character/character_bloc.dart';
import 'package:data_gen_ai/blocs/character/character_event.dart';
import 'package:data_gen_ai/blocs/character/character_state.dart';
import 'package:data_gen_ai/widgets/common/ai_prompt_sheet.dart';
import 'package:data_gen_ai/widgets/common/json_preview_panel.dart';
import 'package:data_gen_ai/widgets/forms/bool_toggle.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/faction_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).extra as String?;
    if (path != null) {
      context.read<CharacterBloc>().add(CharacterLoaded(path));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Character Editor'),
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Character saved')));
            }
          },
          builder: (context, state) {
            final data = state.data;
            final catalog = context.read<RegistryCatalogService>();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: <Widget>[
                  SectionCard(
                    title: 'Identity',
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      onChanged: (value) {
                        context.read<CharacterBloc>().add(
                          CharacterUpdated(data.copyWith(description: value)),
                        );
                      },
                    ),
                  ),
                  SectionCard(
                    title: 'Core',
                    child: Column(
                      children: <Widget>[
                        FactionIdDropdown(
                          catalog: catalog,
                          label: 'Faction (FactionsConfig)',
                          value: data.faction,
                          onChanged: (value) =>
                              context.read<CharacterBloc>().add(
                                CharacterUpdated(data.copyWith(faction: value)),
                              ),
                        ),
                        IntField(
                          label: 'Character Type',
                          initialValue: data.characterType,
                          onChanged: (value) =>
                              context.read<CharacterBloc>().add(
                                CharacterUpdated(
                                  data.copyWith(characterType: value),
                                ),
                              ),
                        ),
                        BoolToggle(
                          label: 'Bake Modular States',
                          value: data.bakeModularStates,
                          onChanged: (value) =>
                              context.read<CharacterBloc>().add(
                                CharacterUpdated(
                                  data.copyWith(bakeModularStates: value),
                                ),
                              ),
                        ),
                      ],
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
            final path = GoRouterState.of(context).extra as String?;
            if (path != null) {
              context.read<CharacterBloc>().add(CharacterSaved(path));
            }
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

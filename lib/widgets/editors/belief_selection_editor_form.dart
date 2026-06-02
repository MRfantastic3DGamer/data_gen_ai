import 'package:data_gen_ai/models/belief_selection_so.dart';
import 'package:data_gen_ai/models/considerable_so.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/considerable_config_editor.dart';
import 'package:data_gen_ai/widgets/forms/consideration_function_config_editor.dart';
import 'package:data_gen_ai/widgets/forms/data_source_toggle.dart';
import 'package:data_gen_ai/widgets/forms/list_editor.dart';
import 'package:data_gen_ai/widgets/forms/reference_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';

class BeliefSelectionEditorForm extends StatefulWidget {
  const BeliefSelectionEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<BeliefSelectionEditorForm> createState() =>
      _BeliefSelectionEditorFormState();
}

class _BeliefSelectionEditorFormState extends State<BeliefSelectionEditorForm> {
  late BeliefSelectionSOModel _model;

  @override
  void initState() {
    super.initState();
    _model = BeliefSelectionSOModel.fromJson(widget.entry.payload);
  }

  void _update(BeliefSelectionSOModel next) {
    setState(() => _model = next);
    widget.onChanged(mergeEntryPayload(widget.entry, next.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Belief',
          child: ReferenceField(
            label: 'Belief asset',
            reference: _model.belief,
            onGuidChanged: (guid) => _update(
              BeliefSelectionSOModel(
                belief: UnityReference(
                  guid: guid,
                  fileId: guid.isEmpty ? 0 : 11400000,
                ),
                considerables: _model.considerables,
              ),
            ),
          ),
        ),
        ListEditor(
          title: 'Considerables',
          itemCount: _model.considerables.length,
          onAdd: () => _update(
            BeliefSelectionSOModel(
              belief: _model.belief,
              considerables: <ConsiderationItemModel>[
                ..._model.considerables,
                const ConsiderationItemModel(),
              ],
            ),
          ),
          itemBuilder: (context, index) {
            final item = _model.considerables[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text('Item ${index + 1}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            final list = List<ConsiderationItemModel>.from(
                              _model.considerables,
                            )..removeAt(index);
                            _update(
                              BeliefSelectionSOModel(
                                belief: _model.belief,
                                considerables: list,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    DataSourceToggle(
                      label: 'Considerable source',
                      value: item.considerableSource,
                      onChanged: (v) {
                        final list = List<ConsiderationItemModel>.from(
                          _model.considerables,
                        );
                        list[index] = ConsiderationItemModel(
                          considerableSource: v,
                          considerableAsset: item.considerableAsset,
                          considerableInline: item.considerableInline,
                          functionSource: item.functionSource,
                          functionAsset: item.functionAsset,
                          functionInline: item.functionInline,
                        );
                        _update(
                          BeliefSelectionSOModel(
                            belief: _model.belief,
                            considerables: list,
                          ),
                        );
                      },
                    ),
                    if (item.considerableSource == 0)
                      ReferenceField(
                        label: 'Considerable asset',
                        reference: item.considerableAsset,
                        onGuidChanged: (guid) {
                          final list = List<ConsiderationItemModel>.from(
                            _model.considerables,
                          );
                          list[index] = ConsiderationItemModel(
                            considerableSource: item.considerableSource,
                            considerableAsset: UnityReference(
                              guid: guid,
                              fileId: guid.isEmpty ? 0 : 11400000,
                            ),
                            considerableInline: item.considerableInline,
                            functionSource: item.functionSource,
                            functionAsset: item.functionAsset,
                            functionInline: item.functionInline,
                          );
                          _update(
                            BeliefSelectionSOModel(
                              belief: _model.belief,
                              considerables: list,
                            ),
                          );
                        },
                      )
                    else
                      ConsiderableConfigEditor(
                        config: ConsiderableConfigModel.fromJson(
                          item.considerableInline,
                        ),
                        onChanged: (cfg) {
                          final list = List<ConsiderationItemModel>.from(
                            _model.considerables,
                          );
                          list[index] = ConsiderationItemModel(
                            considerableSource: item.considerableSource,
                            considerableAsset: item.considerableAsset,
                            considerableInline: cfg.toJson(),
                            functionSource: item.functionSource,
                            functionAsset: item.functionAsset,
                            functionInline: item.functionInline,
                          );
                          _update(
                            BeliefSelectionSOModel(
                              belief: _model.belief,
                              considerables: list,
                            ),
                          );
                        },
                      ),
                    DataSourceToggle(
                      label: 'Function source',
                      value: item.functionSource,
                      onChanged: (v) {
                        final list = List<ConsiderationItemModel>.from(
                          _model.considerables,
                        );
                        list[index] = ConsiderationItemModel(
                          considerableSource: item.considerableSource,
                          considerableAsset: item.considerableAsset,
                          considerableInline: item.considerableInline,
                          functionSource: v,
                          functionAsset: item.functionAsset,
                          functionInline: item.functionInline,
                        );
                        _update(
                          BeliefSelectionSOModel(
                            belief: _model.belief,
                            considerables: list,
                          ),
                        );
                      },
                    ),
                    if (item.functionSource == 0)
                      ReferenceField(
                        label: 'Function asset',
                        reference: item.functionAsset,
                        onGuidChanged: (guid) {
                          final list = List<ConsiderationItemModel>.from(
                            _model.considerables,
                          );
                          list[index] = ConsiderationItemModel(
                            considerableSource: item.considerableSource,
                            considerableAsset: item.considerableAsset,
                            considerableInline: item.considerableInline,
                            functionSource: item.functionSource,
                            functionAsset: UnityReference(
                              guid: guid,
                              fileId: guid.isEmpty ? 0 : 11400000,
                            ),
                            functionInline: item.functionInline,
                          );
                          _update(
                            BeliefSelectionSOModel(
                              belief: _model.belief,
                              considerables: list,
                            ),
                          );
                        },
                      )
                    else
                      ConsiderationFunctionConfigEditor(
                        config: item.functionInline,
                        onChanged: (cfg) {
                          final list = List<ConsiderationItemModel>.from(
                            _model.considerables,
                          );
                          list[index] = ConsiderationItemModel(
                            considerableSource: item.considerableSource,
                            considerableAsset: item.considerableAsset,
                            considerableInline: item.considerableInline,
                            functionSource: item.functionSource,
                            functionAsset: item.functionAsset,
                            functionInline: cfg,
                          );
                          _update(
                            BeliefSelectionSOModel(
                              belief: _model.belief,
                              considerables: list,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

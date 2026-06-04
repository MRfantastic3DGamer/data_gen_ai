import 'package:data_gen_ai/models/actionable_so.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/widgets/forms/action_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/float_field.dart';
import 'package:data_gen_ai/widgets/forms/asset_reference_field.dart';
import 'package:data_gen_ai/widgets/forms/asset_reference_list_editor.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/forms/utility_ai_result_field_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:data_gen_ai/core/theme/editor_preferences_scope.dart';

class ActionableEditorForm extends StatefulWidget {
  const ActionableEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<ActionableEditorForm> createState() => _ActionableEditorFormState();
}

class _ActionableEditorFormState extends State<ActionableEditorForm> {
  late ActionableSOModel _model;

  @override
  void initState() {
    super.initState();
    _model = ActionableSOModel.fromJson(widget.entry.payload);
  }

  void _notify() {
    final payload = Map<String, dynamic>.from(widget.entry.payload)
      ..addAll(_model.toJson());
    widget.onChanged(
      widget.entry.copyWith(payload: payload, isDirty: true),
    );
  }

  void _update(ActionableSOModel next) {
    setState(() => _model = next);
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return EditorFormList(
      children: <Widget>[
        SectionCard(
          title: 'Action',
          child:           ActionIdDropdown(
            label: 'Catalog action',
            value: _model.action,
            onChanged: (v) => _update(_copy(action: v)),
          ),
        ),
        SectionCard(
          title: 'Provided beliefs',
          child: AssetReferenceListEditor(
            references: _model.providedBeliefAssets,
            label: 'Belief SO',
            typeKeys: const <String>['BeliefSO'],
            onChanged: (refs) => _update(_copy(providedBeliefAssets: refs)),
          ),
        ),
        SectionCard(
          title: 'Required beliefs',
          child: AssetReferenceListEditor(
            references: _model.requiredBeliefAssets,
            label: 'Belief SO',
            typeKeys: const <String>['BeliefSO'],
            onChanged: (refs) => _update(_copy(requiredBeliefAssets: refs)),
          ),
        ),
        SectionCard(
          title: 'Cost',
          child: EditorFieldGroup(
            children: <Widget>[
              FloatField(
                label: 'Const cost',
                initialValue: _model.constCost,
                onChanged: (v) => _update(_copy(constCost: v)),
              ),
              AssetReferenceField(
                label: 'Cost query',
                reference: _model.costQuery,
                includeQueryViews: true,
                onChanged: (ref) => _update(_copy(costQuery: ref)),
              ),
              UtilityAIResultFieldDropdown(
                label: 'Cost field',
                value: _model.costField,
                onChanged: (v) => _update(_copy(costField: v)),
              ),
              FloatField(
                label: 'Cost field multiplier',
                initialValue: _model.costFieldMultiplier,
                onChanged: (v) => _update(_copy(costFieldMultiplier: v)),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Time',
          child: EditorFieldGroup(
            children: <Widget>[
              FloatField(
                label: 'Const time',
                initialValue: _model.constTime,
                onChanged: (v) => _update(_copy(constTime: v)),
              ),
              AssetReferenceField(
                label: 'Time query',
                reference: _model.timeQuery,
                includeQueryViews: true,
                onChanged: (ref) => _update(_copy(timeQuery: ref)),
              ),
              UtilityAIResultFieldDropdown(
                label: 'Time field',
                value: _model.timeField,
                onChanged: (v) => _update(_copy(timeField: v)),
              ),
              FloatField(
                label: 'Time field multiplier',
                initialValue: _model.timeFieldMultiplier,
                onChanged: (v) => _update(_copy(timeFieldMultiplier: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ActionableSOModel _copy({
    List<UnityReference>? providedBeliefAssets,
    int? action,
    List<UnityReference>? requiredBeliefAssets,
    double? constCost,
    UnityReference? costQuery,
    int? costField,
    double? costFieldMultiplier,
    double? constTime,
    UnityReference? timeQuery,
    int? timeField,
    double? timeFieldMultiplier,
  }) {
    return ActionableSOModel(
      providedBeliefAssets: providedBeliefAssets ?? _model.providedBeliefAssets,
      action: action ?? _model.action,
      requiredBeliefAssets: requiredBeliefAssets ?? _model.requiredBeliefAssets,
      constCost: constCost ?? _model.constCost,
      costQuery: costQuery ?? _model.costQuery,
      costField: costField ?? _model.costField,
      costFieldMultiplier: costFieldMultiplier ?? _model.costFieldMultiplier,
      constTime: constTime ?? _model.constTime,
      timeQuery: timeQuery ?? _model.timeQuery,
      timeField: timeField ?? _model.timeField,
      timeFieldMultiplier: timeFieldMultiplier ?? _model.timeFieldMultiplier,
    );
  }
}

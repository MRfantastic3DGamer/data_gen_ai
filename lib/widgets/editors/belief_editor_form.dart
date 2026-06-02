import 'package:data_gen_ai/core/enums/belief_condition.dart';
import 'package:data_gen_ai/core/enums/result_field.dart';
import 'package:data_gen_ai/models/belief_so.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/widgets/forms/bool_toggle.dart';
import 'package:data_gen_ai/widgets/forms/float_field.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
import 'package:data_gen_ai/widgets/forms/reference_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/forms/vector3_field.dart';
import 'package:flutter/material.dart';

class BeliefEditorForm extends StatefulWidget {
  const BeliefEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<BeliefEditorForm> createState() => _BeliefEditorFormState();
}

class _BeliefEditorFormState extends State<BeliefEditorForm> {
  late BeliefSOModel _model;

  @override
  void initState() {
    super.initState();
    _model = BeliefSOModel.fromJson(widget.entry.payload);
  }

  void _notify() {
    final payload = Map<String, dynamic>.from(widget.entry.payload)
      ..addAll(_model.toJson());
    widget.onChanged(
      widget.entry.copyWith(payload: payload, isDirty: true),
    );
  }

  void _update(BeliefSOModel next) {
    setState(() => _model = next);
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Query',
          child: ReferenceField(
            label: 'Query view',
            reference: _model.queryViewAsset,
            onGuidChanged: (guid) => _update(
              BeliefSOModel(
                queryViewAsset: UnityReference(
                  guid: guid,
                  fileId: guid.isEmpty ? 0 : 11400000,
                ),
                field: _model.field,
                condition: _model.condition,
                isVectorValue: _model.isVectorValue,
                isRangeValue: _model.isRangeValue,
                intValue: _model.intValue,
                boolValue: _model.boolValue,
                floatValue: _model.floatValue,
                vectorValue: _model.vectorValue,
                rangeValue: _model.rangeValue,
                useHysteresis: _model.useHysteresis,
                hysteresisDelta: _model.hysteresisDelta,
              ),
            ),
          ),
        ),
        SectionCard(
          title: 'Condition',
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<int>(
                value: _model.field,
                decoration: const InputDecoration(labelText: 'Result field'),
                items: UtilityAIResultField.values
                    .map(
                      (f) => DropdownMenuItem<int>(
                        value: f.value,
                        child: Text(f.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) _update(_copy(field: v));
                },
              ),
              DropdownButtonFormField<int>(
                value: _model.condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: BeliefCondition.values
                    .map(
                      (c) => DropdownMenuItem<int>(
                        value: c.value,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) _update(_copy(condition: v));
                },
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Target value',
          child: Column(
            children: <Widget>[
              IntField(
                label: 'Int value',
                initialValue: _model.intValue,
                onChanged: (v) => _update(_copy(intValue: v)),
              ),
              BoolToggle(
                label: 'Bool value',
                value: _model.boolValue,
                onChanged: (v) => _update(_copy(boolValue: v)),
              ),
              FloatField(
                label: 'Float value',
                initialValue: _model.floatValue,
                onChanged: (v) => _update(_copy(floatValue: v)),
              ),
              Vector3Field(
                label: 'Vector value',
                value: _model.vectorValue,
                onChanged: (v) => _update(_copy(vectorValue: v)),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Hysteresis',
          child: Column(
            children: <Widget>[
              BoolToggle(
                label: 'Use hysteresis',
                value: _model.useHysteresis,
                onChanged: (v) => _update(_copy(useHysteresis: v)),
              ),
              FloatField(
                label: 'Hysteresis delta',
                initialValue: _model.hysteresisDelta,
                onChanged: (v) => _update(_copy(hysteresisDelta: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  BeliefSOModel _copy({
    UnityReference? queryViewAsset,
    int? field,
    int? condition,
    int? intValue,
    bool? boolValue,
    double? floatValue,
    Map<String, dynamic>? vectorValue,
    bool? useHysteresis,
    double? hysteresisDelta,
  }) {
    return BeliefSOModel(
      queryViewAsset: queryViewAsset ?? _model.queryViewAsset,
      field: field ?? _model.field,
      condition: condition ?? _model.condition,
      isVectorValue: _model.isVectorValue,
      isRangeValue: _model.isRangeValue,
      intValue: intValue ?? _model.intValue,
      boolValue: boolValue ?? _model.boolValue,
      floatValue: floatValue ?? _model.floatValue,
      vectorValue: vectorValue ?? _model.vectorValue,
      rangeValue: _model.rangeValue,
      useHysteresis: useHysteresis ?? _model.useHysteresis,
      hysteresisDelta: hysteresisDelta ?? _model.hysteresisDelta,
    );
  }
}

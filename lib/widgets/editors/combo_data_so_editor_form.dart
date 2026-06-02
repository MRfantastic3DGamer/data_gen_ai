import 'package:data_gen_ai/models/combo_data_so.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/combo_state_grid_editor.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
import 'package:data_gen_ai/widgets/forms/reference_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';

class ComboDataSOEditorForm extends StatefulWidget {
  const ComboDataSOEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<ComboDataSOEditorForm> createState() => _ComboDataSOEditorFormState();
}

class _ComboDataSOEditorFormState extends State<ComboDataSOEditorForm> {
  late ComboDataSOModel _model;

  @override
  void initState() {
    super.initState();
    _model = ComboDataSOModel.fromJson(widget.entry.payload);
  }

  void _update(ComboDataSOModel next) {
    setState(() => _model = next);
    widget.onChanged(mergeEntryPayload(widget.entry, next.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Combo',
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _model.comboDescription,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (v) => _update(_model.copyWith(comboDescription: v)),
              ),
              IntField(
                label: 'Priority',
                initialValue: _model.priority,
                onChanged: (v) => _update(_model.copyWith(priority: v)),
              ),
              ReferenceField(
                label: 'Animation clip',
                reference: _model.animationClip,
                onGuidChanged: (guid) => _update(
                  _model.copyWith(
                    animationClip: UnityReference(
                      guid: guid,
                      fileId: guid.isEmpty ? 0 : 11400000,
                    ),
                  ),
                ),
              ),
              ReferenceField(
                label: 'Referenced combo',
                reference: _model.referencedCombo,
                onGuidChanged: (guid) => _update(
                  _model.copyWith(
                    referencedCombo: UnityReference(
                      guid: guid,
                      fileId: guid.isEmpty ? 0 : 11400000,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Combo state (12 slots)',
          child: ComboStateGridEditor(
            state: _model.comboState,
            onChanged: (s) => _update(_model.copyWith(comboState: s)),
          ),
        ),
      ],
    );
  }
}

import 'package:data_gen_ai/models/animation_registry.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/list_editor.dart';
import 'package:data_gen_ai/widgets/forms/reference_field.dart';
import 'package:flutter/material.dart';

class AnimationRegistryEditorForm extends StatefulWidget {
  const AnimationRegistryEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<AnimationRegistryEditorForm> createState() =>
      _AnimationRegistryEditorFormState();
}

class _AnimationRegistryEditorFormState
    extends State<AnimationRegistryEditorForm> {
  late AnimationRegistryModel _model;

  @override
  void initState() {
    super.initState();
    _model = AnimationRegistryModel.fromJson(widget.entry.payload);
  }

  void _update(AnimationRegistryModel next) {
    setState(() => _model = next);
    widget.onChanged(mergeEntryPayload(widget.entry, next.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        ListEditor(
          title: 'Character animation databases',
          itemCount: _model.characterDatabases.length,
          onAdd: () => _update(
            _model.copyWith(
              characterDatabases: <UnityReference>[
                ..._model.characterDatabases,
                const UnityReference(guid: '', fileId: 0),
              ],
            ),
          ),
          itemBuilder: (context, index) {
            return ReferenceField(
              label: 'Database ${index + 1}',
              reference: _model.characterDatabases[index],
              onGuidChanged: (guid) {
                final list = List<UnityReference>.from(
                  _model.characterDatabases,
                );
                list[index] = UnityReference(
                  guid: guid,
                  fileId: guid.isEmpty ? 0 : 11400000,
                );
                _update(_model.copyWith(characterDatabases: list));
              },
            );
          },
        ),
      ],
    );
  }
}

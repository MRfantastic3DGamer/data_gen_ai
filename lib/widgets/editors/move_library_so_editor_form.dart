import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/move_library_so.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/animation_type_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/list_editor.dart';
import 'package:data_gen_ai/widgets/forms/raw_map_config_editor.dart';
import 'package:data_gen_ai/widgets/forms/asset_reference_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/editors/editor_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MoveLibrarySOEditorForm extends StatefulWidget {
  const MoveLibrarySOEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<MoveLibrarySOEditorForm> createState() =>
      _MoveLibrarySOEditorFormState();
}

class _MoveLibrarySOEditorFormState extends State<MoveLibrarySOEditorForm> {
  late MoveLibrarySOModel _model;

  @override
  void initState() {
    super.initState();
    _model = MoveLibrarySOModel.fromJson(widget.entry.payload);
  }

  void _update(MoveLibrarySOModel next) {
    setState(() => _model = next);
    widget.onChanged(mergeEntryPayload(widget.entry, next.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<RegistryCatalogService>();
    return EditorListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Default root motion settings',
          child: RawMapConfigEditor(
            raw: _model.defaultSettings,
            fields: const <RawMapFieldSpec>[
              RawMapFieldSpec(
                key: 'EnableRootMotion',
                label: 'Enable root motion',
                kind: RawMapFieldKind.boolField,
                defaultValue: true,
              ),
              RawMapFieldSpec(
                key: 'SampleRate',
                label: 'Sample rate',
                kind: RawMapFieldKind.floatField,
                defaultValue: 60,
              ),
            ],
            onChanged: (raw) => _update(_model.copyWith(defaultSettings: raw)),
          ),
        ),
        ListEditor(
          title: 'Moves',
          itemCount: _model.moves.length,
          onAdd: () => _update(
            _model.copyWith(
              moves: <MoveConfigModel>[..._model.moves, const MoveConfigModel()],
            ),
          ),
          itemBuilder: (context, index) {
            final move = _model.moves[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: move.moveName,
                      decoration: const InputDecoration(labelText: 'Move name'),
                      onChanged: (v) {
                        final list = List<MoveConfigModel>.from(_model.moves);
                        list[index] = move.copyWith(moveName: v);
                        _update(_model.copyWith(moves: list));
                      },
                    ),
                    AnimationTypeIdDropdown(
                      catalog: catalog,
                      label: 'Animation',
                      value: move.animation,
                      onChanged: (v) {
                        final list = List<MoveConfigModel>.from(_model.moves);
                        list[index] = move.copyWith(animation: v);
                        _update(_model.copyWith(moves: list));
                      },
                    ),
                    AssetReferenceField(
                      label: 'Clip',
                      reference: move.clip,
                      onChanged: (ref) {
                        final list = List<MoveConfigModel>.from(_model.moves);
                        list[index] = move.copyWith(clip: ref);
                        _update(_model.copyWith(moves: list));
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

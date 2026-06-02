import 'package:data_gen_ai/models/character_animation_database.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/animation_type_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/faction_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/list_editor.dart';
import 'package:data_gen_ai/widgets/forms/reference_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CharacterAnimationDatabaseEditorForm extends StatefulWidget {
  const CharacterAnimationDatabaseEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<CharacterAnimationDatabaseEditorForm> createState() =>
      _CharacterAnimationDatabaseEditorFormState();
}

class _CharacterAnimationDatabaseEditorFormState
    extends State<CharacterAnimationDatabaseEditorForm> {
  late CharacterAnimationDatabaseModel _model;

  @override
  void initState() {
    super.initState();
    _model = CharacterAnimationDatabaseModel.fromJson(widget.entry.payload);
  }

  void _update(CharacterAnimationDatabaseModel next) {
    setState(() => _model = next);
    widget.onChanged(mergeEntryPayload(widget.entry, next.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<RegistryCatalogService>();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Database',
          child: Column(
            children: <Widget>[
              FactionIdDropdown(
                catalog: catalog,
                label: 'Character faction',
                value: _model.characterFaction,
                onChanged: (v) => _update(_model.copyWith(characterFaction: v)),
              ),
              ReferenceField(
                label: 'Animation types config',
                reference: _model.animationTypes,
                onGuidChanged: (guid) => _update(
                  _model.copyWith(
                    animationTypes: UnityReference(
                      guid: guid,
                      fileId: guid.isEmpty ? 0 : 11400000,
                    ),
                  ),
                ),
              ),
              ReferenceField(
                label: 'Animation data JSON',
                reference: _model.animationDataJson,
                onGuidChanged: (guid) => _update(
                  _model.copyWith(
                    animationDataJson: UnityReference(
                      guid: guid,
                      fileId: guid.isEmpty ? 0 : 11400000,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ListEditor(
          title: 'Animations',
          itemCount: _model.animations.length,
          onAdd: () => _update(
            _model.copyWith(
              animations: <AnimationEntryModel>[
                ..._model.animations,
                const AnimationEntryModel(),
              ],
            ),
          ),
          itemBuilder: (context, index) {
            final row = _model.animations[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    AnimationTypeIdDropdown(
                      catalog: catalog,
                      label: 'Animation type',
                      value: row.animationTypeId,
                      factionId: _model.characterFaction,
                      onChanged: (v) {
                        final list = List<AnimationEntryModel>.from(
                          _model.animations,
                        );
                        list[index] = row.copyWith(animationTypeId: v);
                        _update(_model.copyWith(animations: list));
                      },
                    ),
                    ReferenceField(
                      label: 'Clip',
                      reference: row.clip,
                      onGuidChanged: (guid) {
                        final list = List<AnimationEntryModel>.from(
                          _model.animations,
                        );
                        list[index] = row.copyWith(
                          clip: UnityReference(
                            guid: guid,
                            fileId: guid.isEmpty ? 0 : 11400000,
                          ),
                        );
                        _update(_model.copyWith(animations: list));
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

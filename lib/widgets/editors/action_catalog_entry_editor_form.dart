import 'package:data_gen_ai/models/action_catalog_entry_so.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/animation_type_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
import 'package:data_gen_ai/widgets/forms/list_editor.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/editors/editor_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionCatalogEntryEditorForm extends StatefulWidget {
  const ActionCatalogEntryEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<ActionCatalogEntryEditorForm> createState() =>
      _ActionCatalogEntryEditorFormState();
}

class _ActionCatalogEntryEditorFormState
    extends State<ActionCatalogEntryEditorForm> {
  late ActionCatalogEntrySOModel _model;

  @override
  void initState() {
    super.initState();
    _model = ActionCatalogEntrySOModel.fromJson(widget.entry.payload);
  }

  void _update(ActionCatalogEntrySOModel next) {
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
          title: 'Catalog entry',
          child: Column(
            children: <Widget>[
              IntField(
                label: 'Action ID',
                initialValue: _model.actionId,
                onChanged: (v) => _update(_model.copyWith(actionId: v)),
              ),
              TextFormField(
                initialValue: _model.editorName,
                decoration: const InputDecoration(labelText: 'Editor name'),
                onChanged: (v) => _update(_model.copyWith(editorName: v)),
              ),
              AnimationTypeIdDropdown(
                catalog: catalog,
                label: 'Animation',
                value: _model.animation,
                onChanged: (v) => _update(_model.copyWith(animation: v)),
              ),
              TextFormField(
                initialValue: _model.category,
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (v) => _update(_model.copyWith(category: v)),
              ),
              TextFormField(
                initialValue: _model.gameplayDisplayName,
                decoration: const InputDecoration(
                  labelText: 'Gameplay display name',
                ),
                onChanged: (v) =>
                    _update(_model.copyWith(gameplayDisplayName: v)),
              ),
            ],
          ),
        ),
        ListEditor(
          title: 'Tags',
          itemCount: _model.tags.length,
          onAdd: () => _update(_model.copyWith(tags: <String>[..._model.tags, ''])),
          itemBuilder: (context, index) {
            return TextFormField(
              initialValue: _model.tags[index],
              decoration: InputDecoration(labelText: 'Tag ${index + 1}'),
              onChanged: (v) {
                final tags = List<String>.from(_model.tags);
                tags[index] = v;
                _update(_model.copyWith(tags: tags));
              },
            );
          },
        ),
      ],
    );
  }
}

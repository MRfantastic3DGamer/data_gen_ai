import 'package:data_gen_ai/models/action_catalog_registry.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/editors/editor_list_view.dart';
import 'package:flutter/material.dart';
import 'package:data_gen_ai/core/theme/editor_preferences_scope.dart';

class ActionCatalogRegistryEditorForm extends StatefulWidget {
  const ActionCatalogRegistryEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<ActionCatalogRegistryEditorForm> createState() =>
      _ActionCatalogRegistryEditorFormState();
}

class _ActionCatalogRegistryEditorFormState
    extends State<ActionCatalogRegistryEditorForm> {
  late ActionCatalogRegistryModel _model;

  @override
  void initState() {
    super.initState();
    _model = ActionCatalogRegistryModel.fromJson(widget.entry.payload);
  }

  @override
  Widget build(BuildContext context) {
    return EditorFormList(
      children: <Widget>[
        SectionCard(
          title: 'Registry',
          child: TextFormField(
            initialValue: _model.catalogRoot,
            decoration: const InputDecoration(
              labelText: 'Catalog root folder',
            ),
            onChanged: (v) {
              setState(() => _model = _model.copyWith(catalogRoot: v));
              widget.onChanged(
                mergeEntryPayload(widget.entry, _model.toJson()),
              );
            },
          ),
        ),
      ],
    );
  }
}

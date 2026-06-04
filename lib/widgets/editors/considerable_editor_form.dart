import 'package:data_gen_ai/models/considerable_so.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/considerable_config_editor.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/editors/editor_list_view.dart';
import 'package:flutter/material.dart';
import 'package:data_gen_ai/core/theme/editor_preferences_scope.dart';

class ConsiderableEditorForm extends StatefulWidget {
  const ConsiderableEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<ConsiderableEditorForm> createState() => _ConsiderableEditorFormState();
}

class _ConsiderableEditorFormState extends State<ConsiderableEditorForm> {
  late ConsiderableSOModel _model;

  @override
  void initState() {
    super.initState();
    _model = ConsiderableSOModel.fromJson(widget.entry.payload);
  }

  @override
  Widget build(BuildContext context) {
    return EditorFormList(
      children: <Widget>[
        SectionCard(
          title: 'Considerable config',
          child: ConsiderableConfigEditor(
            config: _model.config,
            onChanged: (cfg) {
              setState(() => _model = ConsiderableSOModel(config: cfg));
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

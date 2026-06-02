import 'package:data_gen_ai/models/consideration_function_so.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/consideration_function_config_editor.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';

class ConsiderationFunctionEditorForm extends StatefulWidget {
  const ConsiderationFunctionEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<ConsiderationFunctionEditorForm> createState() =>
      _ConsiderationFunctionEditorFormState();
}

class _ConsiderationFunctionEditorFormState
    extends State<ConsiderationFunctionEditorForm> {
  late ConsiderationFunctionSOModel _model;

  @override
  void initState() {
    super.initState();
    _model = ConsiderationFunctionSOModel.fromJson(widget.entry.payload);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Function config',
          child: ConsiderationFunctionConfigEditor(
            config: _model.config,
            onChanged: (cfg) {
              setState(() => _model = ConsiderationFunctionSOModel(config: cfg));
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

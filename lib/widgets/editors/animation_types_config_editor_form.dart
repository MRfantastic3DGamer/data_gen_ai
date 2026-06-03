import 'package:data_gen_ai/models/animation_types_config_model.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';

class AnimationTypesConfigEditorForm extends StatefulWidget {
  const AnimationTypesConfigEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<AnimationTypesConfigEditorForm> createState() =>
      _AnimationTypesConfigEditorFormState();
}

class _AnimationTypesConfigEditorFormState
    extends State<AnimationTypesConfigEditorForm> {
  late AnimationTypesConfigModel _model;

  @override
  void initState() {
    super.initState();
    _model = AnimationTypesConfigModel.fromJson(widget.entry.payload);
  }

  void _update(AnimationTypesConfigModel next) {
    setState(() => _model = next);
    widget.onChanged(mergeEntryPayload(widget.entry, next.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Animation types',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Id')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('')),
              ],
              rows: _model.types.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      SizedBox(
                        width: 64,
                        child: TextFormField(
                          key: ValueKey('anim-id-$index-${row.id}'),
                          initialValue: row.id.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final id = int.tryParse(v) ?? row.id;
                            final types = List<AnimationTypeEntryModel>.from(
                              _model.types,
                            );
                            types[index] = AnimationTypeEntryModel(
                              id: id,
                              name: row.name,
                            );
                            _update(_model.copyWith(types: types));
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          key: ValueKey('anim-name-$index'),
                          initialValue: row.name,
                          onChanged: (v) {
                            final types = List<AnimationTypeEntryModel>.from(
                              _model.types,
                            );
                            types[index] = AnimationTypeEntryModel(
                              id: row.id,
                              name: v,
                            );
                            _update(_model.copyWith(types: types));
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          final types = List<AnimationTypeEntryModel>.from(
                            _model.types,
                          )..removeAt(index);
                          _update(_model.copyWith(types: types));
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              final maxId = _model.types.fold<int>(
                0,
                (m, t) => t.id > m ? t.id : m,
              );
              _update(
                _model.copyWith(
                  types: <AnimationTypeEntryModel>[
                    ..._model.types,
                    AnimationTypeEntryModel(id: maxId + 1, name: 'NewType'),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add type'),
          ),
        ),
      ],
    );
  }
}

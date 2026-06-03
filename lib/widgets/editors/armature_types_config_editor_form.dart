import 'package:data_gen_ai/models/armature_types_config_model.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';

class ArmatureTypesConfigEditorForm extends StatefulWidget {
  const ArmatureTypesConfigEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<ArmatureTypesConfigEditorForm> createState() =>
      _ArmatureTypesConfigEditorFormState();
}

class _ArmatureTypesConfigEditorFormState
    extends State<ArmatureTypesConfigEditorForm> {
  late ArmatureTypesConfigModel _model;

  @override
  void initState() {
    super.initState();
    _model = ArmatureTypesConfigModel.fromJson(widget.entry.payload);
  }

  void _update(ArmatureTypesConfigModel next) {
    setState(() => _model = next);
    widget.onChanged(mergeEntryPayload(widget.entry, next.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Armature types',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Id')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('')),
              ],
              rows: _model.armatures.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      SizedBox(
                        width: 64,
                        child: TextFormField(
                          key: ValueKey('arm-id-$index-${row.id}'),
                          initialValue: row.id.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final id = int.tryParse(v) ?? row.id;
                            final armatures = List<ArmatureTypeEntryModel>.from(
                              _model.armatures,
                            );
                            armatures[index] = ArmatureTypeEntryModel(
                              id: id,
                              name: row.name,
                            );
                            _update(_model.copyWith(armatures: armatures));
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                          key: ValueKey('arm-name-$index'),
                          initialValue: row.name,
                          onChanged: (v) {
                            final armatures = List<ArmatureTypeEntryModel>.from(
                              _model.armatures,
                            );
                            armatures[index] = ArmatureTypeEntryModel(
                              id: row.id,
                              name: v,
                            );
                            _update(_model.copyWith(armatures: armatures));
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          final armatures = List<ArmatureTypeEntryModel>.from(
                            _model.armatures,
                          )..removeAt(index);
                          _update(_model.copyWith(armatures: armatures));
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
              final maxId = _model.armatures.fold<int>(
                0,
                (m, a) => a.id > m ? a.id : m,
              );
              _update(
                _model.copyWith(
                  armatures: <ArmatureTypeEntryModel>[
                    ..._model.armatures,
                    ArmatureTypeEntryModel(id: maxId + 1, name: 'Armature'),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add armature'),
          ),
        ),
      ],
    );
  }
}

import 'package:data_gen_ai/models/factions_config_model.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/color_picker_field.dart';
import 'package:data_gen_ai/widgets/forms/faction_relationship_editor.dart';
import 'package:data_gen_ai/widgets/forms/list_editor.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/editors/editor_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FactionsConfigEditorForm extends StatefulWidget {
  const FactionsConfigEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<FactionsConfigEditorForm> createState() =>
      _FactionsConfigEditorFormState();
}

class _FactionsConfigEditorFormState extends State<FactionsConfigEditorForm> {
  late FactionsConfigModel _model;

  @override
  void initState() {
    super.initState();
    _model = FactionsConfigModel.fromJson(widget.entry.payload);
  }

  void _update(FactionsConfigModel next) {
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
          title: 'Factions',
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Id')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Color')),
                DataColumn(label: Text('')),
              ],
              rows: _model.factions.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      SizedBox(
                        width: 64,
                        child: TextFormField(
                          key: ValueKey('faction-id-$index-${row.id}'),
                          initialValue: row.id.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final id = int.tryParse(v) ?? row.id;
                            final factions = List<FactionDefinitionModel>.from(
                              _model.factions,
                            );
                            factions[index] = FactionDefinitionModel(
                              id: id,
                              name: row.name,
                              editorColor: row.editorColor,
                            );
                            _update(_model.copyWith(factions: factions));
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: TextFormField(
                          key: ValueKey('faction-name-$index'),
                          initialValue: row.name,
                          onChanged: (v) {
                            final factions = List<FactionDefinitionModel>.from(
                              _model.factions,
                            );
                            factions[index] = FactionDefinitionModel(
                              id: row.id,
                              name: v,
                              editorColor: row.editorColor,
                            );
                            _update(_model.copyWith(factions: factions));
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      ColorPickerField(
                        label: '',
                        value: row.editorColor,
                        onChanged: (c) {
                          final factions = List<FactionDefinitionModel>.from(
                            _model.factions,
                          );
                          factions[index] = FactionDefinitionModel(
                            id: row.id,
                            name: row.name,
                            editorColor: c,
                          );
                          _update(_model.copyWith(factions: factions));
                        },
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          final factions = List<FactionDefinitionModel>.from(
                            _model.factions,
                          )..removeAt(index);
                          _update(_model.copyWith(factions: factions));
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
              final maxId = _model.factions.fold<int>(
                0,
                (m, f) => f.id > m ? f.id : m,
              );
              _update(
                _model.copyWith(
                  factions: <FactionDefinitionModel>[
                    ..._model.factions,
                    FactionDefinitionModel(
                      id: maxId + 1,
                      name: 'Faction_${maxId + 1}',
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add faction'),
          ),
        ),
        SectionCard(
          title: 'Relationships',
          child: ListEditor(
            title: 'Faction relationships',
            itemCount: _model.relationships.length,
            onAdd: () => _update(
              _model.copyWith(
                relationships: <FactionRelationshipModel>[
                  ..._model.relationships,
                  const FactionRelationshipModel(a: 1, b: 2, type: 1),
                ],
              ),
            ),
            itemBuilder: (context, index) {
              return FactionRelationshipEditor(
                relationship: _model.relationships[index],
                catalog: catalog,
                onChanged: (r) {
                  final relationships = List<FactionRelationshipModel>.from(
                    _model.relationships,
                  );
                  relationships[index] = r;
                  _update(_model.copyWith(relationships: relationships));
                },
                onDelete: () {
                  final relationships = List<FactionRelationshipModel>.from(
                    _model.relationships,
                  )..removeAt(index);
                  _update(_model.copyWith(relationships: relationships));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

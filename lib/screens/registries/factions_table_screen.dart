import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/models/factions_config_model.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/repositories/registry_repository.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/common/registry_catalog_listener.dart';
import 'package:data_gen_ai/widgets/forms/color_picker_field.dart';
import 'package:data_gen_ai/widgets/forms/faction_relationship_editor.dart';
import 'package:data_gen_ai/widgets/forms/list_editor.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FactionsTableScreen extends StatefulWidget {
  const FactionsTableScreen({
    super.key,
    required this.catalog,
    required this.registryRepository,
  });

  final RegistryCatalogService catalog;
  final RegistryRepository registryRepository;

  @override
  State<FactionsTableScreen> createState() => _FactionsTableScreenState();
}

class _FactionsTableScreenState extends State<FactionsTableScreen> {
  List<FactionDefinitionModel> _rows = <FactionDefinitionModel>[];
  List<FactionRelationshipModel> _relationships = <FactionRelationshipModel>[];
  var _saving = false;

  void _loadFromCatalog() {
    final model = widget.catalog.factionsFile?.model;
    setState(() {
      _rows = List<FactionDefinitionModel>.from(
        model?.factions ?? const <FactionDefinitionModel>[],
      );
      _relationships = List<FactionRelationshipModel>.from(
        model?.relationships ?? const <FactionRelationshipModel>[],
      );
    });
  }

  Future<void> _save() async {
    final file = widget.catalog.factionsFile;
    if (file == null) return;

    setState(() => _saving = true);
    try {
      final model = file.model.copyWith(
        factions: _rows,
        relationships: _relationships,
      );
      await widget.registryRepository.saveFactions(file: file, model: model);
      await widget.catalog.reload(context.read<ProjectRepository>());
      if (mounted) {
        context.read<GameDataBloc>().add(const GameDataReloadRequested());
        _loadFromCatalog();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Factions saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RegistryCatalogListener(
      onCatalogReady: _loadFromCatalog,
      child: Builder(
        builder: (context) {
          final file = widget.catalog.factionsFile;
          if (file == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Factions')),
              body: const Center(
                child: Text('FactionsConfig.json not found in your RAW folder.'),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Factions table'),
              actions: <Widget>[
                IconButton(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final maxId = _rows.fold<int>(0, (m, f) => f.id > m ? f.id : m);
                setState(() {
                  _rows.add(
                    FactionDefinitionModel(
                      id: maxId + 1,
                      name: 'Faction_${maxId + 1}',
                    ),
                  );
                });
              },
              child: const Icon(Icons.add),
            ),
            body: ListView(
              padding: const EdgeInsets.all(12),
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Id')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Color')),
                      DataColumn(label: Text('')),
                    ],
                    rows: _rows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(
                            SizedBox(
                              width: 64,
                              child: TextFormField(
                                key: ValueKey('id-$index-${row.id}'),
                                initialValue: row.id.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final id = int.tryParse(v) ?? row.id;
                                  setState(() {
                                    _rows[index] = FactionDefinitionModel(
                                      id: id,
                                      name: row.name,
                                      editorColor: row.editorColor,
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: TextFormField(
                                key: ValueKey('name-$index'),
                                initialValue: row.name,
                                onChanged: (v) {
                                  setState(() {
                                    _rows[index] = FactionDefinitionModel(
                                      id: row.id,
                                      name: v,
                                      editorColor: row.editorColor,
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 120,
                              child: ColorPickerField(
                                label: '',
                                value: row.editorColor,
                                onChanged: (c) {
                                  setState(() {
                                    _rows[index] = FactionDefinitionModel(
                                      id: row.id,
                                      name: row.name,
                                      editorColor: c,
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  setState(() => _rows.removeAt(index)),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Faction relationships',
                  child: ListEditor(
                    title: 'Relationships',
                    itemCount: _relationships.length,
                    onAdd: () => setState(
                      () => _relationships.add(
                        const FactionRelationshipModel(a: 1, b: 2, type: 1),
                      ),
                    ),
                    itemBuilder: (context, index) {
                      return FactionRelationshipEditor(
                        relationship: _relationships[index],
                        catalog: widget.catalog,
                        onChanged: (r) {
                          setState(() {
                            _relationships[index] = r;
                          });
                        },
                        onDelete: () =>
                            setState(() => _relationships.removeAt(index)),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

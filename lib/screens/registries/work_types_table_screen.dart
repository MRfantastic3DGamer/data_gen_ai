import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/models/work_types_config_model.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/repositories/registry_repository.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/common/registry_catalog_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkTypesTableScreen extends StatefulWidget {
  const WorkTypesTableScreen({
    super.key,
    required this.catalog,
    required this.registryRepository,
  });

  final RegistryCatalogService catalog;
  final RegistryRepository registryRepository;

  @override
  State<WorkTypesTableScreen> createState() => _WorkTypesTableScreenState();
}

class _WorkTypesTableScreenState extends State<WorkTypesTableScreen> {
  List<WorkTypeEntryModel> _rows = <WorkTypeEntryModel>[];
  var _saving = false;

  void _loadFromCatalog() {
    setState(() {
      _rows = List<WorkTypeEntryModel>.from(
        widget.catalog.workTypesFile?.model.types ??
            const <WorkTypeEntryModel>[],
      );
    });
  }

  Future<void> _save() async {
    final file = widget.catalog.workTypesFile;
    if (file == null) return;

    setState(() => _saving = true);
    try {
      final model = WorkTypesConfigModel(types: _rows);
      await widget.registryRepository.saveWorkTypes(file: file, model: model);
      await widget.catalog.reload(context.read<ProjectRepository>());
      if (mounted) {
        context.read<GameDataBloc>().add(const GameDataReloadRequested());
        _loadFromCatalog();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work types saved')),
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
          final file = widget.catalog.workTypesFile;
          if (file == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Work types')),
              body: const Center(
                child: Text('WorkTypesConfig.json not found in your RAW folder.'),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Work types'),
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
                final maxId = _rows.fold<int>(0, (m, t) => t.id > m ? t.id : m);
                setState(() {
                  _rows.add(
                    WorkTypeEntryModel(id: maxId + 1, name: 'Work_${maxId + 1}'),
                  );
                });
              },
              child: const Icon(Icons.add),
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('Id')),
                  DataColumn(label: Text('Name')),
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
                            key: ValueKey('work-id-$index-${row.id}'),
                            initialValue: row.id.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final id = int.tryParse(v) ?? row.id;
                              setState(() {
                                _rows[index] = WorkTypeEntryModel(
                                  id: id,
                                  name: row.name,
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
                            key: ValueKey('work-name-$index'),
                            initialValue: row.name,
                            onChanged: (v) {
                              setState(() {
                                _rows[index] = WorkTypeEntryModel(
                                  id: row.id,
                                  name: v,
                                );
                              });
                            },
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(() => _rows.removeAt(index)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

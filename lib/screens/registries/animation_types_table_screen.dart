import 'package:data_gen_ai/models/animation_types_config_model.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/repositories/registry_repository.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/common/registry_catalog_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AnimationTypesTableScreen extends StatefulWidget {
  const AnimationTypesTableScreen({
    super.key,
    required this.catalog,
    required this.registryRepository,
  });

  final RegistryCatalogService catalog;
  final RegistryRepository registryRepository;

  @override
  State<AnimationTypesTableScreen> createState() =>
      _AnimationTypesTableScreenState();
}

class _AnimationTypesTableScreenState extends State<AnimationTypesTableScreen> {
  AnimationTypesConfigFile? _file;
  List<AnimationTypeEntryModel> _rows = <AnimationTypeEntryModel>[];
  var _saving = false;

  void _load(String path) {
    final file = widget.catalog.animationTypesFiles
        .where((f) => f.path == path)
        .firstOrNull;
    setState(() {
      _file = file;
      _rows = List<AnimationTypeEntryModel>.from(
        file?.model.types ?? const <AnimationTypeEntryModel>[],
      );
    });
  }

  Future<void> _save() async {
    final file = _file;
    if (file == null) return;

    setState(() => _saving = true);
    try {
      await widget.registryRepository.saveAnimationTypes(
        file: file,
        model: file.model.copyWith(types: _rows),
      );
      await widget.catalog.reload(context.read<ProjectRepository>());
      if (mounted) {
        _load(file.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animation types saved')),
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
    final path = GoRouterState.of(context).extra as String?;

    return RegistryCatalogListener(
      onCatalogReady: () {
        if (path != null) _load(path);
      },
      child: Builder(
        builder: (context) {
          if (path == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Animation types')),
              body: const Center(child: Text('Missing config path.')),
            );
          }

          final file = _file;
          if (file == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Animation types')),
              body: const Center(child: Text('Config not found.')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(file.displayName),
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
                    AnimationTypeEntryModel(id: maxId + 1, name: 'NewType'),
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
                            key: ValueKey('id-$index-${row.id}'),
                            initialValue: row.id.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final id = int.tryParse(v) ?? row.id;
                              setState(() {
                                _rows[index] = AnimationTypeEntryModel(
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
                          width: 220,
                          child: TextFormField(
                            key: ValueKey('name-$index'),
                            initialValue: row.name,
                            onChanged: (v) {
                              setState(() {
                                _rows[index] = AnimationTypeEntryModel(
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

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}

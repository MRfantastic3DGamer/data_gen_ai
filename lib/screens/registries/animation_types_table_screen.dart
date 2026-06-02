import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/models/animation_types_config_model.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/repositories/registry_repository.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
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
  late List<AnimationTypeEntryModel> _rows;
  var _loading = true;
  var _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).extra as String?;
    if (path != null) {
      _load(path);
    }
  }

  void _load(String path) {
    final file = widget.catalog.animationTypesFiles
        .where((f) => f.path == path)
        .firstOrNull;
    if (file == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _file = file;
      _rows = List<AnimationTypeEntryModel>.from(file.model.types);
      _loading = false;
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
        context.read<GameDataBloc>().add(const GameDataReloadRequested());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Animation types saved to JSON')),
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
    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
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
            _rows.add(AnimationTypeEntryModel(id: maxId + 1, name: 'NewType'));
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
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}

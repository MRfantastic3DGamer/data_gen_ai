import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/models/action_catalog_entry_so.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/forms/animation_type_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ActionsTableScreen extends StatefulWidget {
  const ActionsTableScreen({super.key, required this.catalog});

  final RegistryCatalogService catalog;

  @override
  State<ActionsTableScreen> createState() => _ActionsTableScreenState();
}

class _ActionsTableScreenState extends State<ActionsTableScreen> {
  List<ActionCatalogEntryFile> _entries = <ActionCatalogEntryFile>[];
  var _savingPath = '';

  @override
  void initState() {
    super.initState();
    _reloadFromCatalog();
  }

  void _reloadFromCatalog() {
    setState(() {
      _entries = List<ActionCatalogEntryFile>.from(
        widget.catalog.actionCatalogEntries,
      );
    });
  }

  Future<void> _saveEntry(ActionCatalogEntryFile file) async {
    setState(() => _savingPath = file.path);
    try {
      final index = _entries.indexWhere((e) => e.path == file.path);
      if (index < 0) return;
      final model = _entries[index].model;
      final repository = context.read<ProjectRepository>();
      final envelope = await repository.loadEnvelope(file.path);
      await repository.savePayload(
        path: file.path,
        baseEnvelope: envelope,
        payload: model.toJson(),
      );
      await widget.catalog.reload(repository);
      if (mounted) {
        context.read<GameDataBloc>().add(const GameDataReloadRequested());
        _reloadFromCatalog();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved ${file.displayName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingPath = '');
    }
  }

  void _updateEntry(int index, ActionCatalogEntrySOModel model) {
    final file = _entries[index];
    setState(() {
      _entries[index] = ActionCatalogEntryFile(
        path: file.path,
        displayName: file.displayName,
        envelope: file.envelope,
        model: model,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Action catalog')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No ActionCatalogEntrySO JSON files found.\n\n'
              'Export action catalog entries from Unity under '
              'Assets/GameData/actionable/ then push to Firebase.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Action catalog'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Open file editor',
            icon: const Icon(Icons.open_in_new),
            onPressed: _entries.isEmpty
                ? null
                : () => context.push('/so-edit', extra: _entries.first.path),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final file = _entries[index];
          final model = file.model;
          final saving = _savingPath == file.path;
          return SectionCard(
            title: file.displayName,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                IntField(
                  label: 'Action ID',
                  initialValue: model.actionId,
                  onChanged: (v) => _updateEntry(
                    index,
                    model.copyWith(actionId: v),
                  ),
                ),
                TextFormField(
                  initialValue: model.editorName,
                  decoration: const InputDecoration(labelText: 'Editor name'),
                  onChanged: (v) => _updateEntry(
                    index,
                    model.copyWith(editorName: v),
                  ),
                ),
                AnimationTypeIdDropdown(
                  catalog: widget.catalog,
                  label: 'Animation type',
                  value: model.animation,
                  onChanged: (v) => _updateEntry(
                    index,
                    model.copyWith(animation: v),
                  ),
                ),
                TextFormField(
                  initialValue: model.category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  onChanged: (v) => _updateEntry(
                    index,
                    model.copyWith(category: v),
                  ),
                ),
                TextFormField(
                  initialValue: model.gameplayDisplayName,
                  decoration: const InputDecoration(
                    labelText: 'Gameplay display name',
                  ),
                  onChanged: (v) => _updateEntry(
                    index,
                    model.copyWith(gameplayDisplayName: v),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonal(
                    onPressed: saving ? null : () => _saveEntry(file),
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save entry'),
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

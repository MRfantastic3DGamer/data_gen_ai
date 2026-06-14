import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/models/action_catalog_entry_so.dart';
import 'package:data_gen_ai/models/game_data_tree_node.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/utils/action_catalog_paths.dart';
import 'package:data_gen_ai/utils/game_data_tree_builder.dart';
import 'package:data_gen_ai/widgets/common/game_data_folder_tree_view.dart';
import 'package:data_gen_ai/widgets/forms/animation_type_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionsTableScreen extends StatefulWidget {
  const ActionsTableScreen({super.key, required this.catalog});

  final RegistryCatalogService catalog;

  @override
  State<ActionsTableScreen> createState() => _ActionsTableScreenState();
}

class _ActionsTableScreenState extends State<ActionsTableScreen> {
  final Map<String, ActionCatalogEntryFile> _filesByPath =
      <String, ActionCatalogEntryFile>{};
  List<GameDataTreeNode> _treeRoots = <GameDataTreeNode>[];
  ActionCatalogRegistryFile? _registry;
  ActionCatalogEntryFile? _selected;
  var _savingPath = '';

  @override
  void initState() {
    super.initState();
    _reloadFromCatalog();
  }

  void _reloadFromCatalog() {
    _filesByPath.clear();
    for (final file in widget.catalog.actionCatalogEntries) {
      _filesByPath[file.path] = file;
    }
    _registry = widget.catalog.actionCatalogRegistry;

    final treePaths = _filesByPath.keys.toList();
    if (_registry != null) {
      treePaths.add(_registry!.path);
    }
    treePaths.sort();

    setState(() {
      _treeRoots = GameDataTreeBuilder.fromPaths(treePaths);
      if (_selected != null && !_filesByPath.containsKey(_selected!.path)) {
        _selected = _filesByPath.values.isEmpty ? null : _filesByPath.values.first;
      } else {
        _selected ??= _filesByPath.values.isEmpty ? null : _filesByPath.values.first;
      }
    });
  }

  Future<void> _saveEntry(ActionCatalogEntryFile file) async {
    setState(() => _savingPath = file.path);
    try {
      final model = _filesByPath[file.path]?.model ?? file.model;
      final repository = context.read<ProjectRepository>();
      final envelope = await repository.loadEnvelope(file.path);
      await repository.savePayload(
        path: file.path,
        baseEnvelope: envelope,
        payload: model.toJson(),
      );
      await widget.catalog.reload(repository);
      if (mounted) {
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

  void _updateSelected(ActionCatalogEntrySOModel model) {
    final file = _selected;
    if (file == null) return;
    final updated = ActionCatalogEntryFile(
      path: file.path,
      displayName: file.displayName,
      envelope: file.envelope,
      model: model,
    );
    setState(() {
      _filesByPath[file.path] = updated;
      _selected = updated;
    });
  }

  void _onTreeFileTap(GameDataTreeNode node) {
    final path = node.path;
    if (path == null) return;

    if (_registry != null && path == _registry!.path) {
      return;
    }

    final file = _filesByPath[path];
    if (file != null) {
      setState(() => _selected = file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasEntries = _filesByPath.isNotEmpty;
    final hasRegistry = _registry != null;

    if (!hasEntries && !hasRegistry) {
      return Scaffold(
        appBar: AppBar(title: const Text('Action catalog')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No action catalog JSON found.\n\n'
              'Export from Unity under Assets/GameData/RAW/actionable/ '
              '(registry + nested ActionCatalogEntrySO files), then pull into the app.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final selected = _selected;
    final saving = selected != null && _savingPath == selected.path;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Action catalog'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (hasRegistry)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: SectionCard(
                title: 'Catalog registry',
                subtitle: _registry!.path,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Catalog root: ${_registry!.effectiveCatalogRoot().isEmpty ? "(same folder as registry)" : _registry!.effectiveCatalogRoot()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${_filesByPath.length} catalog entr${_filesByPath.length == 1 ? 'y' : 'ies'} under actionable/',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            flex: 5,
            child: GameDataFolderTreeView(
              roots: _treeRoots,
              initiallyExpandAll: true,
              emptyMessage: 'No catalog entries',
              bottomPadding: 8,
              onFileTap: _onTreeFileTap,
              fileBuilder: (context, node) {
                final path = node.path;
                if (path == null) return const SizedBox.shrink();
                final isRegistry =
                    _registry != null && path == _registry!.path;
                final file = _filesByPath[path];
                final label = isRegistry
                    ? 'Catalog registry'
                    : file != null
                    ? '${file.displayName} [${file.model.actionId}]'
                    : node.name;
                final subtitle = isRegistry
                    ? path
                    : file != null
                    ? ActionCatalogPaths.treePathFromKey(path)
                    : path;
                final selectedPath = _selected?.path;
                return ListTile(
                  dense: true,
                  selected: path == selectedPath,
                  title: Text(label),
                  subtitle: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isRegistry
                      ? const Icon(Icons.folder_special_outlined, size: 20)
                      : Text(
                          file?.model.gameplayDisplayName ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                  onTap: () => _onTreeFileTap(node),
                );
              },
            ),
          ),
          if (selected != null)
            Expanded(
              flex: 4,
              child: Material(
                elevation: 4,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: <Widget>[
                    SectionCard(
                      title: selected.displayName,
                      subtitle: ActionCatalogPaths.treePathFromKey(selected.path),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          IntField(
                            label: 'Action ID',
                            initialValue: selected.model.actionId,
                            onChanged: (v) => _updateSelected(
                              selected.model.copyWith(actionId: v),
                            ),
                          ),
                          TextFormField(
                            initialValue: selected.model.editorName,
                            decoration: const InputDecoration(
                              labelText: 'Editor name',
                            ),
                            onChanged: (v) => _updateSelected(
                              selected.model.copyWith(editorName: v),
                            ),
                          ),
                          AnimationTypeIdDropdown(
                            catalog: widget.catalog,
                            label: 'Animation type',
                            value: selected.model.animation,
                            onChanged: (v) => _updateSelected(
                              selected.model.copyWith(animation: v),
                            ),
                          ),
                          TextFormField(
                            initialValue: selected.model.category,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                            ),
                            onChanged: (v) => _updateSelected(
                              selected.model.copyWith(category: v),
                            ),
                          ),
                          TextFormField(
                            initialValue: selected.model.gameplayDisplayName,
                            decoration: const InputDecoration(
                              labelText: 'Gameplay display name',
                            ),
                            onChanged: (v) => _updateSelected(
                              selected.model.copyWith(gameplayDisplayName: v),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.tonal(
                              onPressed: saving
                                  ? null
                                  : () => _saveEntry(selected),
                              child: saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Save entry'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

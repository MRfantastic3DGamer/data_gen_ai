import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/core/routing/game_data_editor_navigation.dart';
import 'package:data_gen_ai/core/query_view_types.dart';
import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/so_edit_route_args.dart';
import 'package:data_gen_ai/models/unity_envelope.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/core/theme/editor_preferences_scope.dart';
import 'package:data_gen_ai/services/game_data_defaults.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/utils/game_data_key_builder.dart';
import 'package:data_gen_ai/widgets/common/json_preview_panel.dart';
import 'package:data_gen_ai/widgets/editors/action_catalog_entry_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/action_catalog_registry_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/actionable_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/animation_types_config_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/armature_types_config_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/animation_registry_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/factions_config_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/belief_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/belief_selection_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/character_animation_database_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/character_stats_so_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/combo_data_so_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/considerable_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/consideration_function_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/move_library_so_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/query_view_editor.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/game_data_save_location_card.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SODetailEditorScreen extends StatefulWidget {
  const SODetailEditorScreen({super.key});

  @override
  State<SODetailEditorScreen> createState() => _SODetailEditorScreenState();
}

class _SODetailEditorScreenState extends State<SODetailEditorScreen> {
  GameDataFileEntry? _entry;
  var _loading = true;
  String? _error;
  var _isNew = false;

  final _folderController = TextEditingController();
  final _fileNameController = TextEditingController();
  String? _queryViewTypeKey;
  var _saving = false;

  @override
  void dispose() {
    _folderController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = SOEditRouteArgs.tryParse(GoRouterState.of(context).extra);
    if (args == null) return;

    final pathKey = args.existingPath;
    if (_entry != null &&
        !args.isNew &&
        _entry!.path == pathKey &&
        !_isNew) {
      return;
    }

    if (args.isNew && args.typeInfo != null) {
      _initNew(args);
      return;
    }

    if (pathKey != null && (_entry == null || _entry!.path != pathKey)) {
      _loadExisting(pathKey);
    }
  }

  void _initNew(SOEditRouteArgs args) {
    final typeInfo = args.typeInfo!;
    if (typeInfo.key == 'CharacterData' || typeInfo.key == 'ItemData') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        openNewGameDataEditor(context, typeInfo);
      });
      return;
    }
    _queryViewTypeKey = args.queryViewTypeKey ??
        (typeInfo.key == 'BaseQueryViewSO'
            ? QueryViewTypes.all.first.key
            : null);

    final classId = _resolveClassIdentifier(typeInfo, _queryViewTypeKey);
    final payload = GameDataDefaults.payloadFor(
      typeInfo.key,
      queryViewTypeKey: _queryViewTypeKey,
    );

    final folder = args.suggestedFolder ??
        GameDataDefaults.defaultFolderFor(typeInfo.key);

    setState(() {
      _isNew = true;
      _loading = false;
      _error = null;
      _folderController.text = folder;
      _fileNameController.text = args.initialFileName ?? '';
      _entry = GameDataFileEntry(
        path: '',
        fileName: '',
        typeInfo: typeInfo,
        envelope: UnityEnvelope(
          name: '',
          editorClassIdentifier: classId,
          payload: payload,
        ),
        payload: payload,
        isDirty: true,
      );
    });
  }

  String _resolveClassIdentifier(SOTypeInfo typeInfo, String? queryViewKey) {
    if (queryViewKey != null) {
      return QueryViewTypes.byKey(queryViewKey)?.classIdentifier ??
          typeInfo.classIdentifier;
    }
    return typeInfo.classIdentifier;
  }

  Future<void> _loadExisting(String path) async {
    setState(() {
      _loading = true;
      _error = null;
      _isNew = false;
    });
    try {
      final bloc = context.read<GameDataBloc>().state;
      GameDataFileEntry? existing;
      for (final e in bloc.entries) {
        if (e.path == path) {
          existing = e;
          break;
        }
      }
      existing ??= await context.read<ProjectRepository>().loadEntry(path);

      if (!mounted) return;
      final typeKey = existing.typeInfo?.key;
      if (typeKey == 'CharacterData' || typeKey == 'ItemData') {
        openGameDataEditorByPath(
          context,
          path,
          typeKey: typeKey,
          replace: true,
        );
        return;
      }

      _folderController.text = GameDataKeyBuilder.folderFromKey(path);
      _fileNameController.text = GameDataKeyBuilder.baseNameFromKey(path);
      _queryViewTypeKey = QueryViewTypes.fromClassIdentifier(
        existing.envelope.editorClassIdentifier,
      )?.key;

      setState(() {
        _entry = existing;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _onChanged(GameDataFileEntry updated) {
    setState(() => _entry = updated.copyWith(isDirty: true));
    if (!_isNew && updated.path.isNotEmpty) {
      context.read<GameDataBloc>().add(GameDataEntryUpdated(updated));
    }
  }

  void _onQueryTypeChanged(String? key) {
    if (key == null || _entry == null) return;
    final payload = GameDataDefaults.payloadFor(
      'BaseQueryViewSO',
      queryViewTypeKey: key,
    );
    final typeInfo = _entry!.typeInfo!;
    final updated = GameDataFileEntry(
      path: _entry!.path,
      fileName: _entry!.fileName,
      typeInfo: typeInfo,
      envelope: UnityEnvelope(
        name: _entry!.envelope.name,
        editorClassIdentifier: _resolveClassIdentifier(typeInfo, key),
        enabled: _entry!.envelope.enabled,
        editorHideFlags: _entry!.envelope.editorHideFlags,
        serializationData: _entry!.envelope.serializationData,
        payload: payload,
      ),
      payload: payload,
      isDirty: true,
    );
    setState(() {
      _queryViewTypeKey = key;
      _entry = updated;
    });
  }

  Future<void> _save() async {
    final entry = _entry;
    if (entry == null) return;

    final fileName = _fileNameController.text.trim();
    if (fileName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a file name before saving.')),
      );
      return;
    }

    final key = _isNew
        ? GameDataKeyBuilder.build(
            folderPath: _folderController.text,
            fileName: fileName,
          )
        : entry.path;

    setState(() => _saving = true);
    try {
      final repo = context.read<ProjectRepository>();
      final assetName = GameDataKeyBuilder.baseNameFromKey(key);

      if (_isNew || entry.path.isEmpty) {
        final typeInfo = entry.typeInfo;
        if (typeInfo == null) throw StateError('Missing type for new asset');

        await repo.createNewFile(
          typeInfo: typeInfo,
          objectName: assetName,
          folderPath: _folderController.text.trim(),
          payload: entry.payload,
          classIdentifierOverride: entry.envelope.editorClassIdentifier,
        );
      } else {
        await repo.savePayload(
          path: key,
          baseEnvelope: entry.envelope,
          payload: entry.payload,
          name: assetName,
        );
      }

      await context.read<RegistryCatalogService>().reload(repo);
      context.read<GameDataBloc>().add(const GameDataReloadRequested());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved to $key')),
      );

      if (_isNew) {
        context.pop(key);
      } else {
        setState(() {
          _isNew = false;
          _saving = false;
        });
        await _loadExisting(key);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = SOEditRouteArgs.tryParse(GoRouterState.of(context).extra);
    if (args == null && !_loading && _entry == null && _error == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('No file specified. Open an asset from the list.'),
        ),
      );
    }

    if (_loading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Failed to load file.')),
      );
    }

    final entry = _entry!;
    final typeKey = entry.typeInfo?.key;
    final classId = entry.envelope.editorClassIdentifier;
    final isQueryView = queryViewTypeFromIdentifier(classId) != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'New ${entry.typeLabel}' : entry.displayName),
        actions: <Widget>[
          if (entry.isDirty)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Chip(label: Text('Unsaved')),
            ),
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GameDataSaveLocationCard(
              folderController: _folderController,
              fileNameController: _fileNameController,
              readOnly: !_isNew,
            ),
            if (isQueryView && _isNew)
              SectionCard(
                title: 'Query type',
                child: DropdownButtonFormField<String>(
                  value: _queryViewTypeKey,
                  decoration: const InputDecoration(
                    labelText: 'Query view class',
                  ),
                  items: QueryViewTypes.all
                      .map(
                        (t) => DropdownMenuItem<String>(
                          value: t.key,
                          child: Text(t.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: _onQueryTypeChanged,
                ),
              ),
            _buildEditor(typeKey, classId, isQueryView, entry),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        icon: const Icon(Icons.save_rounded),
        label: Text(_isNew ? 'Save new file' : 'Save'),
      ),
    );
  }

  Widget _buildEditor(
    String? typeKey,
    String classId,
    bool isQueryView,
    GameDataFileEntry entry,
  ) {
    if (isQueryView) {
      return QueryViewEditorForm(entry: entry, onChanged: _onChanged);
    }

    switch (typeKey) {
      case 'ActionableSO':
        return ActionableEditorForm(entry: entry, onChanged: _onChanged);
      case 'BeliefSO':
        return BeliefEditorForm(entry: entry, onChanged: _onChanged);
      case 'BeliefSelectionSO':
        return BeliefSelectionEditorForm(entry: entry, onChanged: _onChanged);
      case 'ConsiderableSO':
        return ConsiderableEditorForm(entry: entry, onChanged: _onChanged);
      case 'ConsiderationFunctionSO':
        return ConsiderationFunctionEditorForm(
          entry: entry,
          onChanged: _onChanged,
        );
      case 'ActionCatalogEntrySO':
        return ActionCatalogEntryEditorForm(entry: entry, onChanged: _onChanged);
      case 'ActionCatalogRegistry':
        return ActionCatalogRegistryEditorForm(
          entry: entry,
          onChanged: _onChanged,
        );
      case 'CharacterAnimationDatabase':
        return CharacterAnimationDatabaseEditorForm(
          entry: entry,
          onChanged: _onChanged,
        );
      case 'CharacterStatsSO':
        return CharacterStatsSOEditorForm(entry: entry, onChanged: _onChanged);
      case 'ComboDataSO':
        return ComboDataSOEditorForm(entry: entry, onChanged: _onChanged);
      case 'MoveLibrarySO':
        return MoveLibrarySOEditorForm(entry: entry, onChanged: _onChanged);
      case 'AnimationRegistry':
        return AnimationRegistryEditorForm(entry: entry, onChanged: _onChanged);
      case 'FactionsConfig':
        return FactionsConfigEditorForm(entry: entry, onChanged: _onChanged);
      case 'AnimationTypesConfig':
        return AnimationTypesConfigEditorForm(
          entry: entry,
          onChanged: _onChanged,
        );
      case 'ArmatureTypesConfig':
        return ArmatureTypesConfigEditorForm(
          entry: entry,
          onChanged: _onChanged,
        );
      default:
        if (classId.contains('FactionsConfig')) {
          return FactionsConfigEditorForm(entry: entry, onChanged: _onChanged);
        }
        if (classId.contains('AnimationTypesConfig')) {
          return AnimationTypesConfigEditorForm(
            entry: entry,
            onChanged: _onChanged,
          );
        }
        if (classId.contains('ArmatureTypesConfig')) {
          return ArmatureTypesConfigEditorForm(
            entry: entry,
            onChanged: _onChanged,
          );
        }
        return EditorFormList(
          children: <Widget>[
            SectionCard(
              title: 'JSON payload (${entry.typeLabel})',
              child: SizedBox(
                height: 500,
                child: JsonPreviewPanel(json: entry.payload),
              ),
            ),
          ],
        );
    }
  }
}

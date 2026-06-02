import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_state.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/widgets/common/json_preview_panel.dart';
import 'package:data_gen_ai/widgets/editors/action_catalog_entry_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/action_catalog_registry_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/actionable_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/animation_registry_editor_form.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final path = GoRouterState.of(context).extra as String?;
    if (path != null && (_entry == null || _entry!.path != path)) {
      _load(path);
    }
  }

  Future<void> _load(String path) async {
    setState(() {
      _loading = true;
      _error = null;
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
      if (existing != null) {
        if (!mounted) return;
        setState(() {
          _entry = existing;
          _loading = false;
        });
        return;
      }

      final entry = await context.read<ProjectRepository>().loadEntry(path);
      if (!mounted) return;
      setState(() {
        _entry = entry;
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
    setState(() => _entry = updated);
    context.read<GameDataBloc>().add(GameDataEntryUpdated(updated));
  }

  @override
  Widget build(BuildContext context) {
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(entry.displayName),
            Text(
              entry.typeLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: <Widget>[
          if (entry.isDirty)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(label: Text('Unsaved')),
            ),
        ],
      ),
      body: _buildEditor(typeKey, classId, isQueryView, entry),
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
      default:
        if (classId.contains('CharacterStatsSO')) {
          return CharacterStatsSOEditorForm(entry: entry, onChanged: _onChanged);
        }
        if (classId.contains('ComboDataSO')) {
          return ComboDataSOEditorForm(entry: entry, onChanged: _onChanged);
        }
        if (classId.contains('MoveLibrarySO')) {
          return MoveLibrarySOEditorForm(entry: entry, onChanged: _onChanged);
        }
        if (classId.contains('AnimationRegistry')) {
          return AnimationRegistryEditorForm(
            entry: entry,
            onChanged: _onChanged,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(12),
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

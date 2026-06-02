import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_state.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/widgets/common/json_preview_panel.dart';
import 'package:data_gen_ai/widgets/editors/actionable_editor_form.dart';
import 'package:data_gen_ai/widgets/editors/belief_editor_form.dart';
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
      body: _buildEditor(typeKey, entry),
    );
  }

  Widget _buildEditor(String? typeKey, GameDataFileEntry entry) {
    switch (typeKey) {
      case 'ActionableSO':
        return ActionableEditorForm(entry: entry, onChanged: _onChanged);
      case 'BeliefSO':
        return BeliefEditorForm(entry: entry, onChanged: _onChanged);
      default:
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

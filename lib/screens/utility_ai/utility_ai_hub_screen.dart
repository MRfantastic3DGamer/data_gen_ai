import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_state.dart';
import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/so_edit_route_args.dart';
import 'package:data_gen_ai/utils/game_data_key_builder.dart';
import 'package:data_gen_ai/widgets/common/game_data_list_tile.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Hub for beliefs, belief selection, considerables, and queries.
class UtilityAIHubScreen extends StatefulWidget {
  const UtilityAIHubScreen({super.key});

  @override
  State<UtilityAIHubScreen> createState() => _UtilityAIHubScreenState();
}

class _UtilityAIHubScreenState extends State<UtilityAIHubScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GameDataBloc>().add(const GameDataStarted());
  }

  static bool _isQueryEntry(GameDataFileEntry entry) {
    return queryViewTypeFromIdentifier(
          entry.envelope.editorClassIdentifier,
        ) !=
        null;
  }

  List<GameDataFileEntry> _filter(
    List<GameDataFileEntry> entries,
    bool Function(GameDataFileEntry) test,
  ) {
    return entries.where(test).toList()
      ..sort(
        (a, b) => GameDataKeyBuilder.baseNameFromKey(a.path).compareTo(
          GameDataKeyBuilder.baseNameFromKey(b.path),
        ),
      );
  }

  void _openNew(BuildContext context, SOTypeInfo typeInfo) {
    context.push(
      '/so-edit',
      extra: SOEditRouteArgs(
        typeInfo: typeInfo,
        suggestedFolder: typeInfo.subfolder.isNotEmpty
            ? typeInfo.subfolder
            : null,
      ),
    );
  }

  void _openNewQuery(BuildContext context) {
    context.push(
      '/so-edit',
      extra: const SOEditRouteArgs(
        typeInfo: SOTypeInfo(
          key: 'BaseQueryViewSO',
          displayName: 'Query View',
          classIdentifier: 'Assembly-CSharp::AI.DataModels.QueryViews',
          subfolder: 'queries',
          category: 'Queries',
        ),
        suggestedFolder: 'queries',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utility AI'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<GameDataBloc>().add(const GameDataReloadRequested());
            },
          ),
        ],
      ),
      body: BlocBuilder<GameDataBloc, GameDataState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = state.entries;
          return ListView(
            padding: AppSpacing.pagePadding(context),
            children: <Widget>[
              _Section(
                title: 'Beliefs',
                entries: _filter(
                  entries,
                  (e) => e.typeInfo?.key == 'BeliefSO',
                ),
                onNew: () => _openNew(
                  context,
                  SOTypeRegistry.all.firstWhere((t) => t.key == 'BeliefSO'),
                ),
              ),
              _Section(
                title: 'Belief selection',
                entries: _filter(
                  entries,
                  (e) => e.typeInfo?.key == 'BeliefSelectionSO',
                ),
                onNew: () => _openNew(
                  context,
                  SOTypeRegistry.all.firstWhere(
                    (t) => t.key == 'BeliefSelectionSO',
                  ),
                ),
              ),
              _Section(
                title: 'Considerables',
                subtitle:
                    'Standalone considerable assets (functions are inline in belief selection)',
                entries: _filter(
                  entries,
                  (e) => e.typeInfo?.key == 'ConsiderableSO',
                ),
                onNew: () => _openNew(
                  context,
                  SOTypeRegistry.all.firstWhere((t) => t.key == 'ConsiderableSO'),
                ),
              ),
              _Section(
                title: 'Queries',
                entries: _filter(entries, _isQueryEntry),
                onNew: () => _openNewQuery(context),
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.animation_rounded),
                  title: const Text('Animation types configs'),
                  subtitle: const Text(
                    'Create Humanoid-style type tables for other armatures',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/registries/animation-types'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.entries,
    required this.onNew,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<GameDataFileEntry> entries;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New'),
            ),
          ],
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(
              'No files yet — tap New to create one.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...entries.map(
            (entry) => GameDataListTile(
              title: GameDataKeyBuilder.baseNameFromKey(entry.path),
              subtitle: entry.typeLabel,
              typeLabel: entry.typeLabel,
              filePath: entry.path,
              isDirty: entry.isDirty,
              onTap: () => context.push(
                '/so-edit',
                extra: SOEditRouteArgs(existingPath: entry.path),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

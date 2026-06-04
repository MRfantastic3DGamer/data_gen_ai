import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_state.dart';
import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/widgets/common/app_snackbar.dart';
import 'package:data_gen_ai/widgets/common/empty_state.dart';
import 'package:data_gen_ai/utils/game_data_tree_builder.dart';
import 'package:data_gen_ai/widgets/common/game_data_folder_tree_view.dart';
import 'package:data_gen_ai/widgets/common/game_data_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ActionsHubScreen extends StatefulWidget {
  const ActionsHubScreen({super.key});

  @override
  State<ActionsHubScreen> createState() => _ActionsHubScreenState();
}

class _ActionsHubScreenState extends State<ActionsHubScreen> {
  final _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    context.read<GameDataBloc>().add(const GameDataStarted());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Game Data'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reload JSON',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<GameDataBloc>().add(const GameDataReloadRequested());
            },
          ),
          IconButton(
            tooltip: 'Data folder',
            icon: const Icon(Icons.folder_open_rounded),
            onPressed: () => context.push('/data-folder'),
          ),
        ],
      ),
      body: BlocConsumer<GameDataBloc, GameDataState>(
        listener: (context, state) {
          if (state.savedMessage != null) {
            AppSnackBar.showSuccess(context, state.savedMessage!);
          }
          if (state.error != null) {
            AppSnackBar.showError(context, state.error!);
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Search name, path, or type…',
                  leading: const Icon(Icons.search_rounded),
                  trailing: state.searchQuery.isNotEmpty
                      ? <Widget>[
                          IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              context.read<GameDataBloc>().add(
                                const GameDataSearchChanged(''),
                              );
                            },
                          ),
                        ]
                      : null,
                  onChanged: (q) => context.read<GameDataBloc>().add(
                    GameDataSearchChanged(q),
                  ),
                  elevation: WidgetStateProperty.all(0),
                  backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  children: <Widget>[
                    _filterChip(
                      context,
                      label: 'All',
                      selected: state.categoryFilter == null,
                      onTap: () => context.read<GameDataBloc>().add(
                        const GameDataCategoryFilterChanged(null),
                      ),
                    ),
                    for (final category in SOTypeRegistry.categories)
                      _filterChip(
                        context,
                        label: category,
                        selected: state.categoryFilter == category,
                        onTap: () => context.read<GameDataBloc>().add(
                          GameDataCategoryFilterChanged(category),
                        ),
                      ),
                  ],
                ),
              ),
              if (state.dirtyCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Card(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              '${state.dirtyCount} unsaved change(s)',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: state.committing
                                ? null
                                : () => context.read<GameDataBloc>().add(
                                    const GameDataCommitRequested(),
                                  ),
                            child: state.committing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Commit'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Expanded(child: _buildList(context, state)),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          BlocBuilder<GameDataBloc, GameDataState>(
            builder: (context, state) {
              if (state.dirtyCount == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FloatingActionButton.extended(
                  heroTag: 'commit',
                  onPressed: state.committing
                      ? null
                      : () => context.read<GameDataBloc>().add(
                          const GameDataCommitRequested(),
                        ),
                  icon: const Icon(Icons.save_rounded),
                  label: Text('Commit (${state.dirtyCount})'),
                ),
              );
            },
          ),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _showCreateSheet(context),
            child: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        showCheckmark: true,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildList(BuildContext context, GameDataState state) {
    final entries = state.filteredEntries;
    if (entries.isEmpty) {
      return EmptyState(
        message:
            'No JSON files found.\n\nExport from Unity, copy RAW to your phone, then set the data folder.',
        icon: Icons.folder_off_outlined,
        actionLabel: 'Open data folder',
        onAction: () => context.push('/data-folder'),
      );
    }

    final roots = GameDataTreeBuilder.fromEntries(entries);

    return GameDataFolderTreeView(
      roots: roots,
      initiallyExpandAll: state.searchQuery.trim().isNotEmpty,
      onFileTap: (node) {
        final path = node.path;
        if (path != null) {
          context.push('/so-edit', extra: path);
        }
      },
      fileBuilder: (context, node) {
        final entry = node.entry;
        if (entry == null) return const SizedBox.shrink();
        return Dismissible(
          key: ValueKey<String>(entry.path),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete asset?'),
                    content: Text(
                      'Remove "${entry.displayName}" from storage on commit?\n\n${entry.path}',
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) {
            context.read<GameDataBloc>().add(
              GameDataDeleteRequested(entry.path),
            );
            AppSnackBar.showSuccess(
              context,
              'Marked for deletion — commit to remove from storage.',
            );
          },
          child: GameDataListTile(
            title: entry.displayName,
            subtitle: entry.path,
            typeLabel: entry.typeLabel,
            isDirty: entry.isDirty,
            onTap: () => context.push('/so-edit', extra: entry.path),
          ),
        );
      },
    );
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    final createTypes = SOTypeRegistry.all;
    SOTypeInfo? selected = createTypes.first;
    final nameController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'New Scriptable Object',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<SOTypeInfo>(
                value: selected,
                decoration: const InputDecoration(labelText: 'Type'),
                items: createTypes
                    .map(
                      (t) => DropdownMenuItem<SOTypeInfo>(
                        value: t,
                        child: Text(t.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selected = v,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Asset name (file name)',
                ),
                textCapitalization: TextCapitalization.none,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty || selected == null) return;
                  context.read<GameDataBloc>().add(
                    GameDataCreateRequested(typeInfo: selected!, name: name),
                  );
                  Navigator.pop(sheetContext);
                },
                child: const Text('Create JSON file'),
              ),
            ],
          ),
        );
      },
    );
  }
}

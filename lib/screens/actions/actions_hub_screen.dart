import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_state.dart';
import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/widgets/common/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ActionsHubScreen extends StatefulWidget {
  const ActionsHubScreen({super.key});

  @override
  State<ActionsHubScreen> createState() => _ActionsHubScreenState();
}

class _ActionsHubScreenState extends State<ActionsHubScreen> {
  final _searchController = TextEditingController();

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
        title: const Text('Actions & GameData'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reload JSON',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<GameDataBloc>().add(const GameDataReloadRequested());
            },
          ),
          IconButton(
            tooltip: 'Data folder',
            icon: const Icon(Icons.folder_open),
            onPressed: () => context.push('/data-folder'),
          ),
        ],
      ),
      body: BlocConsumer<GameDataBloc, GameDataState>(
        listener: (context, state) {
          if (state.savedMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.savedMessage!)),
            );
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search name, path, or type…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<GameDataBloc>().add(
                                const GameDataSearchChanged(''),
                              );
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (q) => context.read<GameDataBloc>().add(
                    GameDataSearchChanged(q),
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                MaterialBanner(
                  content: Text(
                    '${state.dirtyCount} unsaved change(s). Tap Commit to write JSON files.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: state.committing
                          ? null
                          : () => context.read<GameDataBloc>().add(
                              const GameDataCommitRequested(),
                            ),
                      child: state.committing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Commit'),
                    ),
                  ],
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
                  icon: const Icon(Icons.save),
                  label: Text('Commit (${state.dirtyCount})'),
                ),
              );
            },
          ),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _showCreateSheet(context),
            child: const Icon(Icons.add),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildList(BuildContext context, GameDataState state) {
    final entries = state.filteredEntries;
    if (entries.isEmpty) {
      return const EmptyState(
        message:
            'No JSON files found.\n\nExport from Unity (Tools → Agent Actions → Export GameData…), copy Assets/GameData/RAW to your phone, then set the data folder.',
      );
    }

    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) => _entryTile(context, entries[index]),
    );
  }

  Widget _entryTile(BuildContext context, GameDataFileEntry entry) {
    return ListTile(
      leading: Icon(
        entry.isDirty ? Icons.edit_note : Icons.description_outlined,
        color: entry.isDirty ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(entry.displayName),
      subtitle: Text('${entry.typeLabel} · ${entry.path.split('/').last}'),
      trailing: entry.isDirty
          ? const Icon(Icons.circle, size: 10, color: Colors.orange)
          : null,
      onTap: () => context.push('/so-edit', extra: entry.path),
    );
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    final actionTypes = SOTypeRegistry.all
        .where((t) => t.category == 'Actions' || t.category == 'Queries')
        .toList();
    SOTypeInfo? selected = actionTypes.first;
    final nameController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'New Scriptable Object',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SOTypeInfo>(
                value: selected,
                decoration: const InputDecoration(labelText: 'Type'),
                items: actionTypes
                    .map(
                      (t) => DropdownMenuItem<SOTypeInfo>(
                        value: t,
                        child: Text(t.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selected = v,
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Asset name (file name)',
                ),
              ),
              const SizedBox(height: 12),
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

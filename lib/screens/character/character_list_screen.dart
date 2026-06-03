import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_event.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_state.dart';
import 'package:data_gen_ai/core/game_data_path.dart';
import 'package:data_gen_ai/widgets/common/empty_state.dart';
import 'package:data_gen_ai/widgets/common/game_data_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  State<CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GameDataBloc>().add(const GameDataStarted());
  }

  static String _titleFromPath(String path) {
    final file = GameDataPath.fileNameFromKey(path);
    return file.endsWith('.json') ? file.substring(0, file.length - 5) : file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Characters')),
      body: BlocBuilder<GameDataBloc, GameDataState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final characters = state.entries
              .where((e) => e.typeInfo?.key == 'CharacterData')
              .toList()
            ..sort((a, b) => _titleFromPath(a.path).compareTo(
                  _titleFromPath(b.path),
                ));

          if (characters.isEmpty) {
            return const EmptyState(
              message:
                  'No character JSON files found.\n\n'
                  'Pull from Firebase or add files under Characters/ in your local folder.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final entry = characters[index];
              final parent = entry.path.contains('/')
                  ? entry.path.substring(0, entry.path.lastIndexOf('/'))
                  : '';
              return GameDataListTile(
                title: _titleFromPath(entry.path),
                subtitle: parent.isEmpty ? entry.category : parent,
                typeLabel: entry.typeLabel,
                filePath: entry.path,
                isDirty: entry.isDirty,
                onTap: () => context.push('/characters/edit', extra: entry.path),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/characters/edit'),
        icon: const Icon(Icons.add),
        label: const Text('New Character'),
      ),
    );
  }
}

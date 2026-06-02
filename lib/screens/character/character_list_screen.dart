import 'package:data_gen_ai/blocs/project/project_bloc.dart';
import 'package:data_gen_ai/blocs/project/project_state.dart';
import 'package:data_gen_ai/models/character_data.dart';
import 'package:data_gen_ai/widgets/common/empty_state.dart';
import 'package:data_gen_ai/widgets/visualization/character_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Characters')),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          final characterPaths = state.paths
              .where((path) => path.toLowerCase().contains('characters'))
              .toList();
          if (characterPaths.isEmpty) {
            return const EmptyState(
              message: 'No character JSON files found in RAW folder.',
            );
          }
          return ListView.builder(
            itemCount: characterPaths.length,
            itemBuilder: (context, index) {
              final path = characterPaths[index];
              return CharacterSummaryCard(
                data: const CharacterDataModel(description: 'Character'),
                onTap: () => context.push('/characters/edit', extra: path),
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

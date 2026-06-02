import 'package:data_gen_ai/blocs/project/project_bloc.dart';
import 'package:data_gen_ai/blocs/project/project_state.dart';
import 'package:data_gen_ai/models/item_data.dart';
import 'package:data_gen_ai/widgets/common/empty_state.dart';
import 'package:data_gen_ai/widgets/visualization/item_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Items')),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          final itemPaths = state.paths
              .where((path) => path.toLowerCase().contains('items'))
              .toList();
          if (itemPaths.isEmpty) {
            return const EmptyState(
              message: 'No item JSON files found in RAW folder.',
            );
          }
          return ListView.builder(
            itemCount: itemPaths.length,
            itemBuilder: (context, index) {
              final path = itemPaths[index];
              return ItemSummaryCard(
                data: const ItemDataModel(itemId: 'Item'),
                onTap: () => context.push('/items/edit', extra: path),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/items/edit'),
        icon: const Icon(Icons.add),
        label: const Text('New Item'),
      ),
    );
  }
}

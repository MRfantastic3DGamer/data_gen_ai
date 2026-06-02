import 'package:data_gen_ai/blocs/project/project_bloc.dart';
import 'package:data_gen_ai/blocs/project/project_state.dart';
import 'package:data_gen_ai/widgets/common/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SOBrowserScreen extends StatelessWidget {
  const SOBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Scriptable Objects')),
      body: BlocBuilder<ProjectBloc, ProjectState>(
        builder: (context, state) {
          if (state.paths.isEmpty) {
            return const EmptyState(message: 'No JSON assets found.');
          }
          return ListView.builder(
            itemCount: state.paths.length,
            itemBuilder: (context, index) {
              final path = state.paths[index];
              return ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(path.split('/').last),
                subtitle: Text(path),
                onTap: () => context.push('/generic', extra: path),
              );
            },
          );
        },
      ),
    );
  }
}

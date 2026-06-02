import 'package:data_gen_ai/blocs/game_data/game_data_bloc.dart';
import 'package:data_gen_ai/blocs/game_data/game_data_state.dart';
import 'package:data_gen_ai/models/registry_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Resolves action catalog entry ids from loaded GameData files.
class ActionCatalogService {
  const ActionCatalogService._();

  static List<RegistryOption<int>> actionOptions(BuildContext context) {
    final entries = context.read<GameDataBloc>().state.entries;
    final options = <RegistryOption<int>>[
      const RegistryOption<int>(label: '(None) [-1]', value: -1),
    ];
    for (final entry in entries) {
      final id = entry.envelope.editorClassIdentifier;
      if (!id.contains('ActionCatalogEntrySO')) continue;
      final actionId = (entry.payload['actionId'] ?? 0) as int;
      final name =
          (entry.payload['editorName'] ?? entry.displayName) as String;
      options.add(
        RegistryOption<int>(
          label: '$name [$actionId]',
          value: actionId,
        ),
      );
    }
    options.sort((a, b) => a.value.compareTo(b.value));
    return options;
  }
}

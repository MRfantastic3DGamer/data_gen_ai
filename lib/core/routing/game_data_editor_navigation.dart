import 'package:data_gen_ai/core/so_type_registry.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/so_edit_route_args.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Opens the dedicated editor for a game data file when one exists.
void openGameDataEditor(BuildContext context, GameDataFileEntry entry) {
  openGameDataEditorByPath(
    context,
    entry.path,
    typeKey: entry.typeInfo?.key,
  );
}

void openGameDataEditorByPath(
  BuildContext context,
  String path, {
  String? typeKey,
  bool replace = false,
}) {
  void navigate(String location, {Object? extra}) {
    if (replace) {
      context.replace(location, extra: extra);
    } else {
      context.push(location, extra: extra);
    }
  }

  switch (typeKey) {
    case 'CharacterData':
      navigate('/characters/edit', extra: path);
      return;
    case 'ItemData':
      navigate('/items/edit', extra: path);
      return;
    default:
      navigate('/so-edit', extra: path);
  }
}

void openNewGameDataEditor(BuildContext context, SOTypeInfo typeInfo) {
  switch (typeInfo.key) {
    case 'CharacterData':
      context.push('/characters/edit');
      return;
    case 'ItemData':
      context.push('/items/edit');
      return;
    default:
      context.push(
        '/so-edit',
        extra: SOEditRouteArgs(typeInfo: typeInfo),
      );
  }
}

void openNewGameDataEditorWithDetails(
  BuildContext context, {
  required SOTypeInfo typeInfo,
  required String suggestedFolder,
  required String initialFileName,
}) {
  switch (typeInfo.key) {
    case 'CharacterData':
      context.push('/characters/edit');
      return;
    case 'ItemData':
      context.push('/items/edit');
      return;
    default:
      context.push(
        '/so-edit',
        extra: SOEditRouteArgs(
          typeInfo: typeInfo,
          suggestedFolder: suggestedFolder,
          initialFileName: initialFileName,
        ),
      );
  }
}

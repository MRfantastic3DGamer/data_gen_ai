import 'package:data_gen_ai/models/asset_picker_option.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:equatable/equatable.dart';

/// One node in the GameData folder tree (folder or JSON file leaf).
class GameDataTreeNode extends Equatable {
  const GameDataTreeNode.folder({
    required this.name,
    this.children = const <GameDataTreeNode>[],
  }) : path = null,
       entry = null,
       option = null;

  const GameDataTreeNode.file({
    required this.name,
    required this.path,
    this.entry,
    this.option,
  }) : children = const <GameDataTreeNode>[];

  final String name;
  final String? path;
  final List<GameDataTreeNode> children;
  final GameDataFileEntry? entry;
  final AssetPickerOption? option;

  bool get isFolder => children.isNotEmpty;

  bool get isLeaf => !isFolder;

  @override
  List<Object?> get props => <Object?>[name, path, children.length];
}

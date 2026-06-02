import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/unity_reference.dart';

/// One selectable asset in a searchable reference picker.
class AssetPickerOption {
  const AssetPickerOption({
    required this.guid,
    required this.fileId,
    required this.label,
    required this.subtitle,
    required this.typeKey,
    this.path,
    this.entry,
  });

  final String guid;
  final int fileId;
  final String label;
  final String subtitle;
  final String typeKey;
  final String? path;
  final GameDataFileEntry? entry;

  bool get hasGuid => guid.isNotEmpty;

  UnityReference toReference() => UnityReference(
    guid: guid,
    fileId: fileId,
    type: 2,
  );

  static const empty = AssetPickerOption(
    guid: '',
    fileId: 0,
    label: '(None)',
    subtitle: '',
    typeKey: '',
  );
}

/// Generic searchable option for int/string registry dropdowns.
class SearchableOption<T> {
  const SearchableOption({
    required this.value,
    required this.label,
    this.subtitle = '',
    this.searchTerms = '',
  });

  final T value;
  final String label;
  final String subtitle;
  final String searchTerms;

  String get searchableText =>
      '$label $subtitle $searchTerms'.toLowerCase();
}

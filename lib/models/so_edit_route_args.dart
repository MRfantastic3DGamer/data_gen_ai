import 'package:data_gen_ai/core/so_type_registry.dart';

/// Arguments for [SODetailEditorScreen] (new asset or existing path).
class SOEditRouteArgs {
  const SOEditRouteArgs({
    this.existingPath,
    this.typeInfo,
    this.suggestedFolder,
    this.queryViewTypeKey,
    this.initialFileName,
  }) : assert(
         existingPath != null || typeInfo != null,
         'Provide existingPath or typeInfo for a new asset',
       );

  final String? existingPath;
  final SOTypeInfo? typeInfo;
  final String? suggestedFolder;
  final String? queryViewTypeKey;
  final String? initialFileName;

  bool get isNew => existingPath == null || existingPath!.isEmpty;

  static SOEditRouteArgs? tryParse(Object? extra) {
    if (extra == null) return null;
    if (extra is SOEditRouteArgs) return extra;
    if (extra is String) {
      return extra.isEmpty
          ? null
          : SOEditRouteArgs(existingPath: extra);
    }
    return null;
  }
}

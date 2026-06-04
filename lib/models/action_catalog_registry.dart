import 'package:data_gen_ai/utils/unity_json_fields.dart';

class ActionCatalogRegistryModel {
  const ActionCatalogRegistryModel({this.catalogRoot = ''});

  final String catalogRoot;

  factory ActionCatalogRegistryModel.fromJson(Map<String, dynamic> json) =>
      ActionCatalogRegistryModel(
        catalogRoot: UnityJsonFields.asString(json['catalogRoot']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'catalogRoot': catalogRoot};

  ActionCatalogRegistryModel copyWith({String? catalogRoot}) {
    return ActionCatalogRegistryModel(
      catalogRoot: catalogRoot ?? this.catalogRoot,
    );
  }
}

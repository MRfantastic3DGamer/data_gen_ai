class ActionCatalogRegistryModel {
  const ActionCatalogRegistryModel({this.catalogRoot = ''});

  final String catalogRoot;

  factory ActionCatalogRegistryModel.fromJson(Map<String, dynamic> json) =>
      ActionCatalogRegistryModel(
        catalogRoot: (json['catalogRoot'] ?? '') as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{'catalogRoot': catalogRoot};

  ActionCatalogRegistryModel copyWith({String? catalogRoot}) {
    return ActionCatalogRegistryModel(
      catalogRoot: catalogRoot ?? this.catalogRoot,
    );
  }
}

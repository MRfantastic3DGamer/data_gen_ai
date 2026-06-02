class ActionCatalogEntrySOModel {
  const ActionCatalogEntrySOModel({
    this.actionId = 0,
    this.editorName = '',
    this.animation = 0,
    this.category = '',
    this.gameplayDisplayName = '',
    this.tags = const <String>[],
  });

  final int actionId;
  final String editorName;
  final int animation;
  final String category;
  final String gameplayDisplayName;
  final List<String> tags;

  factory ActionCatalogEntrySOModel.fromJson(Map<String, dynamic> json) =>
      ActionCatalogEntrySOModel(
        actionId: (json['actionId'] ?? 0) as int,
        editorName: (json['editorName'] ?? '') as String,
        animation: (json['animation'] ?? 0) as int,
        category: (json['category'] ?? '') as String,
        gameplayDisplayName: (json['gameplayDisplayName'] ?? '') as String,
        tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic e) => '$e')
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'actionId': actionId,
    'editorName': editorName,
    'animation': animation,
    'category': category,
    'gameplayDisplayName': gameplayDisplayName,
    'tags': tags,
  };

  ActionCatalogEntrySOModel copyWith({
    int? actionId,
    String? editorName,
    int? animation,
    String? category,
    String? gameplayDisplayName,
    List<String>? tags,
  }) {
    return ActionCatalogEntrySOModel(
      actionId: actionId ?? this.actionId,
      editorName: editorName ?? this.editorName,
      animation: animation ?? this.animation,
      category: category ?? this.category,
      gameplayDisplayName: gameplayDisplayName ?? this.gameplayDisplayName,
      tags: tags ?? this.tags,
    );
  }
}

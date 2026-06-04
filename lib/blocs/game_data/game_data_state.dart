import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:equatable/equatable.dart';

class GameDataState extends Equatable {
  const GameDataState({
    this.loading = false,
    this.committing = false,
    this.entries = const <GameDataFileEntry>[],
    this.pendingDeletes = const <String>{},
    this.searchQuery = '',
    this.categoryFilter,
    this.typeFilter,
    this.error,
    this.lastCommitCount,
    this.savedMessage,
  });

  final bool loading;
  final bool committing;
  final List<GameDataFileEntry> entries;
  final Set<String> pendingDeletes;
  final String searchQuery;
  final String? categoryFilter;
  final String? typeFilter;
  final String? error;
  final int? lastCommitCount;
  final String? savedMessage;

  int get dirtyCount =>
      entries.where((e) => e.isDirty).length + pendingDeletes.length;

  List<GameDataFileEntry> get filteredEntries {
    var result = entries;
    if (categoryFilter != null && categoryFilter!.isNotEmpty) {
      result = result.where((e) => e.category == categoryFilter).toList();
    }
    if (typeFilter != null && typeFilter!.isNotEmpty) {
      result = result
          .where((e) => e.typeInfo?.key == typeFilter)
          .toList();
    }
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result
          .where(
            (e) =>
                e.displayName.toLowerCase().contains(q) ||
                e.path.toLowerCase().contains(q) ||
                e.typeLabel.toLowerCase().contains(q) ||
                (e.typeInfo?.classIdentifier.toLowerCase().contains(q) ??
                    false),
          )
          .toList();
    }
    return result;
  }

  GameDataState copyWith({
    bool? loading,
    bool? committing,
    List<GameDataFileEntry>? entries,
    Set<String>? pendingDeletes,
    String? searchQuery,
    String? categoryFilter,
    String? typeFilter,
    String? error,
    int? lastCommitCount,
    String? savedMessage,
    bool clearSavedMessage = false,
    bool clearError = false,
  }) {
    return GameDataState(
      loading: loading ?? this.loading,
      committing: committing ?? this.committing,
      entries: entries ?? this.entries,
      pendingDeletes: pendingDeletes ?? this.pendingDeletes,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      error: clearError ? null : (error ?? this.error),
      lastCommitCount: lastCommitCount,
      savedMessage: clearSavedMessage
          ? null
          : (savedMessage ?? this.savedMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    loading,
    committing,
    entries,
    pendingDeletes,
    searchQuery,
    categoryFilter,
    typeFilter,
    error,
    lastCommitCount,
    savedMessage,
    dirtyCount,
  ];
}

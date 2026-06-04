import 'package:data_gen_ai/models/action_catalog_entry_so.dart';
import 'package:data_gen_ai/models/animation_types_config_model.dart';
import 'package:data_gen_ai/models/armature_types_config_model.dart';
import 'package:data_gen_ai/models/factions_config_model.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/registry_option.dart';
import 'package:data_gen_ai/models/work_types_config_model.dart';
import 'package:data_gen_ai/models/unity_envelope.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';

/// Indexes registry tables (factions, animation types, work types, action catalog).
class RegistryCatalogService {
  FactionsConfigFile? factionsFile;
  WorkTypesConfigFile? workTypesFile;
  final List<AnimationTypesConfigFile> animationTypesFiles =
      <AnimationTypesConfigFile>[];
  final List<ArmatureTypesConfigFile> armatureTypesFiles =
      <ArmatureTypesConfigFile>[];
  final List<ActionCatalogEntryFile> actionCatalogEntries =
      <ActionCatalogEntryFile>[];

  final Map<int, AnimationTypesConfigFile> factionToTypesFile =
      <int, AnimationTypesConfigFile>{};

  final Map<String, AnimationTypesConfigFile> typesByGuid =
      <String, AnimationTypesConfigFile>{};

  final Map<String, AnimationTypesConfigFile> typesByPathStem =
      <String, AnimationTypesConfigFile>{};

  final Map<int, String> _actionIdLabels = <int, String>{};

  bool get isLoaded =>
      factionsFile != null ||
      animationTypesFiles.isNotEmpty ||
      actionCatalogEntries.isNotEmpty;

  Future<void> reload(ProjectRepository repository) async {
    factionsFile = null;
    workTypesFile = null;
    animationTypesFiles.clear();
    armatureTypesFiles.clear();
    actionCatalogEntries.clear();
    factionToTypesFile.clear();
    typesByGuid.clear();
    typesByPathStem.clear();
    _actionIdLabels.clear();

    final entries = await repository.loadAllEntries();
    final databases = <GameDataFileEntry>[];

    for (final entry in entries) {
      final id = entry.envelope.editorClassIdentifier;
      if (id.contains('FactionsConfig')) {
        factionsFile = FactionsConfigFile(
          path: entry.path,
          envelope: entry.envelope,
          model: FactionsConfigModel.fromJson(entry.payload),
        );
      } else if (id.contains('WorkTypesConfig')) {
        workTypesFile = WorkTypesConfigFile(
          path: entry.path,
          envelope: entry.envelope,
          model: WorkTypesConfigModel.fromJson(entry.payload),
        );
      } else if (id.contains('AnimationTypesConfig')) {
        final file = AnimationTypesConfigFile(
          path: entry.path,
          displayName: entry.displayName,
          guid: '',
          model: AnimationTypesConfigModel.fromJson(entry.payload),
        );
        animationTypesFiles.add(file);
        typesByPathStem[_pathStem(entry.path)] = file;
      } else if (id.contains('ArmatureTypesConfig')) {
        armatureTypesFiles.add(
          ArmatureTypesConfigFile(
            path: entry.path,
            displayName: entry.displayName,
            envelope: entry.envelope,
            model: ArmatureTypesConfigModel.fromJson(entry.payload),
          ),
        );
      } else if (id.contains('ActionCatalogEntrySO')) {
        final model = ActionCatalogEntrySOModel.fromJson(entry.payload);
        actionCatalogEntries.add(
          ActionCatalogEntryFile(
            path: entry.path,
            displayName: entry.displayName,
            envelope: entry.envelope,
            model: model,
          ),
        );
        _registerActionLabel(model.actionId, _actionEntryLabel(model, entry));
      } else if (id.contains('ActionableSO')) {
        final actionId = (entry.payload['action'] ?? -1) as int;
        if (actionId >= 0) {
          _registerActionLabel(actionId, '${entry.displayName} [$actionId]');
        }
      } else if (id.contains('CharacterAnimationDatabase')) {
        databases.add(entry);
      }
    }

    animationTypesFiles.sort(
      (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );
    actionCatalogEntries.sort(
      (a, b) => a.model.actionId.compareTo(b.model.actionId),
    );
    armatureTypesFiles.sort(
      (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );

    for (final db in databases) {
      _linkDatabase(db);
    }

    for (final entry in entries) {
      _scanRefs(entry.payload, (ref) {
        final matched = ref.assetKey.isNotEmpty
            ? _fileForTypesAssetKey(ref.assetKey)
            : _fileForTypesGuid(ref.guid);
        if (matched != null && ref.guid.isNotEmpty) {
          typesByGuid[ref.guid] = matched;
        }
      });
    }
  }

  void _linkDatabase(GameDataFileEntry entry) {
    final faction = (entry.payload['characterFaction'] ?? 0) as int;
    final typesRef = UnityReference.fromJson(
      entry.payload['animationTypes'] as Map<String, dynamic>?,
    );

    var matched = typesRef.guid.isNotEmpty ? typesByGuid[typesRef.guid] : null;
    matched ??= _fileForTypesAssetKey(typesRef.assetKey);
    matched ??= _matchTypesFileForDatabase(entry, faction);
    if (matched == null && animationTypesFiles.length == 1) {
      matched = animationTypesFiles.first;
    }
    matched ??= _matchTypesFileForFaction(faction);
    if (matched == null) return;

    final index = animationTypesFiles.indexWhere((f) => f.path == matched!.path);
    if (index >= 0) {
      animationTypesFiles[index] = AnimationTypesConfigFile(
        path: matched.path,
        displayName: matched.displayName,
        guid: typesRef.guid.isNotEmpty ? typesRef.guid : matched.guid,
        model: matched.model,
        factionId: faction,
      );
      matched = animationTypesFiles[index];
    }

    factionToTypesFile[faction] = matched;
    if (typesRef.guid.isNotEmpty) {
      typesByGuid[typesRef.guid] = matched;
    }
  }

  AnimationTypesConfigFile? _matchTypesFileForDatabase(
    GameDataFileEntry databaseEntry,
    int factionId,
  ) {
    final dbStem = _pathStem(databaseEntry.path).toLowerCase();
    for (final file in animationTypesFiles) {
      final typesStem = _pathStem(file.path).toLowerCase();
      if (dbStem.contains(typesStem) || typesStem.contains(dbStem)) {
        return file;
      }
    }
    return _matchTypesFileForFaction(factionId);
  }

  AnimationTypesConfigFile? _matchTypesFileForFaction(int factionId) {
    final name = factionLabel(factionId).toLowerCase();
    for (final file in animationTypesFiles) {
      final pathLower = file.path.toLowerCase();
      if (name != 'none' && pathLower.contains(name)) return file;
    }
    if (animationTypesFiles.length == 1) return animationTypesFiles.first;
    return null;
  }

  AnimationTypesConfigFile? _fileForTypesGuid(String guid) {
    if (guid.isEmpty) return null;
    return typesByGuid[guid];
  }

  AnimationTypesConfigFile? _fileForTypesAssetKey(String assetKey) {
    if (assetKey.isEmpty) return null;
    for (final file in animationTypesFiles) {
      if (file.path == assetKey) return file;
    }
    return null;
  }

  void _scanRefs(
    Object? node,
    void Function(UnityReference ref) onRef,
  ) {
    if (node is Map<String, dynamic>) {
      if (node.containsKey('assetKey') ||
          (node.containsKey('guid') && node.containsKey('fileID'))) {
        onRef(UnityReference.fromJson(node));
      }
      for (final value in node.values) {
        _scanRefs(value, onRef);
      }
    } else if (node is List<dynamic>) {
      for (final item in node) {
        _scanRefs(item, onRef);
      }
    }
  }

  void _registerActionLabel(int actionId, String label) {
    if (actionId < 0) return;
    final existing = _actionIdLabels[actionId];
    if (existing == null || existing.startsWith('Action_')) {
      _actionIdLabels[actionId] = label;
    }
  }

  String _actionEntryLabel(
    ActionCatalogEntrySOModel model,
    GameDataFileEntry entry,
  ) {
    final name = model.editorName.trim();
    if (name.isNotEmpty) return '$name [${model.actionId}]';
    return '${entry.displayName} [${model.actionId}]';
  }

  static String _pathStem(String path) {
    final fileName = path.split('/').last;
    return fileName.replaceAll('.json', '');
  }

  List<RegistryOption<int>> factionOptions({bool allowNone = true}) {
    final options = <RegistryOption<int>>[];
    if (allowNone) {
      options.add(const RegistryOption<int>(label: '(None) [0]', value: 0));
    }
    final factions = factionsFile?.model.factions ?? const <FactionDefinitionModel>[];
    for (final f in factions) {
      options.add(
        RegistryOption<int>(label: '${f.name} [${f.id}]', value: f.id),
      );
    }
    return options;
  }

  List<RegistryOption<int>> animationTypeOptions({
    String? typesConfigGuid,
    int? factionId,
  }) {
    final config = resolveTypesConfig(
      typesConfigGuid: typesConfigGuid,
      factionId: factionId,
    );
    final options = <RegistryOption<int>>[
      const RegistryOption<int>(label: '(None) [0]', value: 0),
    ];
    if (config == null) return options;

    for (final t in config.model.types) {
      options.add(
        RegistryOption<int>(label: '${t.name} [${t.id}]', value: t.id),
      );
    }
    return options;
  }

  List<RegistryOption<int>> actionOptions() {
    final options = <RegistryOption<int>>[
      const RegistryOption<int>(label: '(None) [-1]', value: -1),
    ];
    final ids = _actionIdLabels.keys.toList()..sort();
    for (final id in ids) {
      options.add(
        RegistryOption<int>(
          label: _actionIdLabels[id] ?? 'Action_$id [$id]',
          value: id,
        ),
      );
    }
    return options;
  }

  AnimationTypesConfigFile? resolveTypesConfig({
    String? typesConfigGuid,
    int? factionId,
  }) {
    if (typesConfigGuid != null &&
        typesConfigGuid.isNotEmpty &&
        typesByGuid.containsKey(typesConfigGuid)) {
      return typesByGuid[typesConfigGuid];
    }
    if (factionId != null && factionToTypesFile.containsKey(factionId)) {
      return factionToTypesFile[factionId];
    }
    if (animationTypesFiles.length == 1) return animationTypesFiles.first;
    return null;
  }

  String factionLabel(int id) {
    return factionsFile?.model.nameForId(id) ?? (id == 0 ? 'NONE' : 'Faction_$id');
  }
}

class FactionsConfigFile {
  const FactionsConfigFile({
    required this.path,
    required this.envelope,
    required this.model,
  });

  final String path;
  final UnityEnvelope envelope;
  final FactionsConfigModel model;
}

class WorkTypesConfigFile {
  const WorkTypesConfigFile({
    required this.path,
    required this.envelope,
    required this.model,
  });

  final String path;
  final UnityEnvelope envelope;
  final WorkTypesConfigModel model;
}

class ActionCatalogEntryFile {
  const ActionCatalogEntryFile({
    required this.path,
    required this.displayName,
    required this.envelope,
    required this.model,
  });

  final String path;
  final String displayName;
  final UnityEnvelope envelope;
  final ActionCatalogEntrySOModel model;
}

import 'package:data_gen_ai/models/animation_types_config_model.dart';
import 'package:data_gen_ai/models/factions_config_model.dart';
import 'package:data_gen_ai/models/work_types_config_model.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/registry_option.dart';
import 'package:data_gen_ai/models/unity_envelope.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';

/// Indexes FactionsConfig and AnimationTypesConfig exports (Unity registry tables).
class RegistryCatalogService {
  FactionsConfigFile? factionsFile;
  WorkTypesConfigFile? workTypesFile;
  final List<AnimationTypesConfigFile> animationTypesFiles =
      <AnimationTypesConfigFile>[];

  final Map<int, AnimationTypesConfigFile> factionToTypesFile =
      <int, AnimationTypesConfigFile>{};

  final Map<String, AnimationTypesConfigFile> typesByGuid =
      <String, AnimationTypesConfigFile>{};

  bool get isLoaded => factionsFile != null || animationTypesFiles.isNotEmpty;

  Future<void> reload(ProjectRepository repository) async {
    factionsFile = null;
    workTypesFile = null;
    animationTypesFiles.clear();
    factionToTypesFile.clear();
    typesByGuid.clear();

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
        animationTypesFiles.add(
          AnimationTypesConfigFile(
            path: entry.path,
            displayName: entry.displayName,
            guid: '',
            model: AnimationTypesConfigModel.fromJson(entry.payload),
          ),
        );
      } else if (id.contains('CharacterAnimationDatabase')) {
        databases.add(entry);
      }
    }

    animationTypesFiles.sort(
      (a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    );

    for (final db in databases) {
      _linkDatabase(db);
    }

    // Learn guids from any reference in all payloads pointing at a known types path.
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
    if (typesByGuid.containsKey(guid)) return typesByGuid[guid];
    return null;
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

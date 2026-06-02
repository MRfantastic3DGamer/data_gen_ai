import 'package:data_gen_ai/models/animation_types_config_model.dart';
import 'package:data_gen_ai/models/factions_config_model.dart';
import 'package:data_gen_ai/models/work_types_config_model.dart';
import 'package:data_gen_ai/repositories/project_repository.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';

class RegistryRepository {
  RegistryRepository(this._projectRepository);

  final ProjectRepository _projectRepository;

  Future<void> saveFactions({
    required FactionsConfigFile file,
    required FactionsConfigModel model,
  }) async {
    final payload = model.copyWith(bakeVersion: model.bakeVersion + 1).toJson();
    await _projectRepository.savePayload(
      path: file.path,
      baseEnvelope: file.envelope,
      payload: payload,
    );
  }

  Future<void> saveAnimationTypes({
    required AnimationTypesConfigFile file,
    required AnimationTypesConfigModel model,
  }) async {
    await _projectRepository.savePayload(
      path: file.path,
      baseEnvelope: await _projectRepository.loadEnvelope(file.path),
      payload: model.toJson(),
    );
  }

  Future<void> saveWorkTypes({
    required WorkTypesConfigFile file,
    required WorkTypesConfigModel model,
  }) async {
    await _projectRepository.savePayload(
      path: file.path,
      baseEnvelope: file.envelope,
      payload: model.toJson(),
    );
  }
}

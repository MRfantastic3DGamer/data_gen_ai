import 'package:data_gen_ai/models/eat_config.dart';
import 'package:data_gen_ai/models/nav_config.dart';
import 'package:data_gen_ai/models/play_animation_config.dart';
import 'package:data_gen_ai/models/reserve_slot_config.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/models/wait_config.dart';

class ActuatorMappingModel {
  const ActuatorMappingModel({
    this.action = 0,
    this.actuatorType = 1,
    this.navigateConfig = const NavigateConfigModel(),
    this.waitConfig = const WaitConfigModel(),
    this.eatingInteractionConfig = const EatConfigModel(),
    this.reserveSlotConfig = const ReserveSlotConfigModel(),
    this.playAnimationConfig = const PlayAnimationConfigModel(),
    this.avatarMask = const UnityReference(guid: '', fileId: 0),
    this.navigateQueryView = const UnityReference(guid: '', fileId: 0),
    this.navigateResultField = 22,
    this.reserveSlotQueryView = const UnityReference(guid: '', fileId: 0),
    this.reserveSlotResultField = 30,
    this.eatPrimaryQueryView = const UnityReference(guid: '', fileId: 0),
    this.eatPrimaryResultField = 30,
  });

  final int action;
  final int actuatorType;
  final NavigateConfigModel navigateConfig;
  final WaitConfigModel waitConfig;
  final EatConfigModel eatingInteractionConfig;
  final ReserveSlotConfigModel reserveSlotConfig;
  final PlayAnimationConfigModel playAnimationConfig;
  final UnityReference avatarMask;
  final UnityReference navigateQueryView;
  final int navigateResultField;
  final UnityReference reserveSlotQueryView;
  final int reserveSlotResultField;
  final UnityReference eatPrimaryQueryView;
  final int eatPrimaryResultField;

  factory ActuatorMappingModel.fromJson(Map<String, dynamic> json) =>
      ActuatorMappingModel(
        action: (json['action'] ?? 0) as int,
        actuatorType: (json['actuatorType'] ?? 1) as int,
        navigateConfig: NavigateConfigModel.fromJson(
          json['navigateConfig'] as Map<String, dynamic>?,
        ),
        waitConfig: WaitConfigModel.fromJson(
          json['waitConfig'] as Map<String, dynamic>?,
        ),
        eatingInteractionConfig: EatConfigModel.fromJson(
          json['eatingInteractionConfig'] as Map<String, dynamic>?,
        ),
        reserveSlotConfig: ReserveSlotConfigModel.fromJson(
          json['reserveSlotConfig'] as Map<String, dynamic>?,
        ),
        playAnimationConfig: PlayAnimationConfigModel.fromJson(
          json['playAnimationConfig'] as Map<String, dynamic>?,
        ),
        avatarMask: UnityReference.fromJson(
          json['avatarMask'] as Map<String, dynamic>?,
        ),
        navigateQueryView: UnityReference.fromJson(
          json['navigateQueryView'] as Map<String, dynamic>?,
        ),
        navigateResultField: (json['navigateResultField'] ?? 22) as int,
        reserveSlotQueryView: UnityReference.fromJson(
          json['reserveSlotQueryView'] as Map<String, dynamic>?,
        ),
        reserveSlotResultField: (json['reserveSlotResultField'] ?? 30) as int,
        eatPrimaryQueryView: UnityReference.fromJson(
          json['eatPrimaryQueryView'] as Map<String, dynamic>?,
        ),
        eatPrimaryResultField: (json['eatPrimaryResultField'] ?? 30) as int,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'action': action,
    'actuatorType': actuatorType,
    'navigateConfig': navigateConfig.toJson(),
    'waitConfig': waitConfig.toJson(),
    'eatingInteractionConfig': eatingInteractionConfig.toJson(),
    'reserveSlotConfig': reserveSlotConfig.toJson(),
    'playAnimationConfig': playAnimationConfig.toJson(),
    'avatarMask': avatarMask.toJson(),
    'navigateQueryView': navigateQueryView.toJson(),
    'navigateResultField': navigateResultField,
    'reserveSlotQueryView': reserveSlotQueryView.toJson(),
    'reserveSlotResultField': reserveSlotResultField,
    'eatPrimaryQueryView': eatPrimaryQueryView.toJson(),
    'eatPrimaryResultField': eatPrimaryResultField,
  };
}

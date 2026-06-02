import 'package:data_gen_ai/core/enums/actuator_type.dart';
import 'package:data_gen_ai/models/actuator_mapping.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/widgets/forms/action_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/config/eat_config_form.dart';
import 'package:data_gen_ai/widgets/forms/config/navigate_config_form.dart';
import 'package:data_gen_ai/widgets/forms/config/play_animation_config_form.dart';
import 'package:data_gen_ai/widgets/forms/config/reserve_slot_config_form.dart';
import 'package:data_gen_ai/widgets/forms/config/wait_config_form.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/reference_field.dart';
import 'package:data_gen_ai/widgets/forms/utility_ai_result_field_dropdown.dart';
import 'package:flutter/material.dart';

class ActuatorMappingRowEditor extends StatelessWidget {
  const ActuatorMappingRowEditor({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onDelete,
    this.factionId,
  });

  final ActuatorMappingModel value;
  final ValueChanged<ActuatorMappingModel> onChanged;
  final VoidCallback onDelete;
  final int? factionId;

  ActuatorMappingModel _copy({
    int? action,
    int? actuatorType,
    NavigateConfigModel? navigateConfig,
    WaitConfigModel? waitConfig,
    EatConfigModel? eatingInteractionConfig,
    ReserveSlotConfigModel? reserveSlotConfig,
    PlayAnimationConfigModel? playAnimationConfig,
    UnityReference? navigateQueryView,
    int? navigateResultField,
  }) {
    return ActuatorMappingModel(
      action: action ?? value.action,
      actuatorType: actuatorType ?? value.actuatorType,
      navigateConfig: navigateConfig ?? value.navigateConfig,
      waitConfig: waitConfig ?? value.waitConfig,
      eatingInteractionConfig:
          eatingInteractionConfig ?? value.eatingInteractionConfig,
      reserveSlotConfig: reserveSlotConfig ?? value.reserveSlotConfig,
      playAnimationConfig: playAnimationConfig ?? value.playAnimationConfig,
      avatarMask: value.avatarMask,
      navigateQueryView: navigateQueryView ?? value.navigateQueryView,
      navigateResultField: navigateResultField ?? value.navigateResultField,
      reserveSlotQueryView: value.reserveSlotQueryView,
      reserveSlotResultField: value.reserveSlotResultField,
      eatPrimaryQueryView: value.eatPrimaryQueryView,
      eatPrimaryResultField: value.eatPrimaryResultField,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Actuator mapping',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                ),
              ],
            ),
            ActionIdDropdown(
              label: 'Action',
              value: value.action,
              onChanged: (v) => onChanged(_copy(action: v)),
            ),
            EnumDropdown(
              label: 'Actuator type',
              value: value.actuatorType,
              options: {
                for (final e in ActuatorType.values) e.value: e.name,
              },
              onChanged: (v) => onChanged(_copy(actuatorType: v)),
            ),
            if (value.actuatorType == ActuatorType.navigateToPosition.value) ...[
              NavigateConfigForm(
                config: value.navigateConfig,
                onChanged: (c) => onChanged(_copy(navigateConfig: c)),
              ),
              ReferenceField(
                label: 'Navigate query view',
                reference: value.navigateQueryView,
                onGuidChanged: (guid) => onChanged(
                  _copy(
                    navigateQueryView: UnityReference(
                      guid: guid,
                      fileId: guid.isEmpty ? 0 : 11400000,
                    ),
                  ),
                ),
              ),
              UtilityAIResultFieldDropdown(
                label: 'Navigate result field',
                value: value.navigateResultField,
                onChanged: (v) => onChanged(_copy(navigateResultField: v)),
              ),
            ],
            if (value.actuatorType == ActuatorType.wait.value)
              WaitConfigForm(
                config: value.waitConfig,
                factionId: factionId,
                onChanged: (c) => onChanged(_copy(waitConfig: c)),
              ),
            if (value.actuatorType == ActuatorType.eat.value)
              EatConfigForm(
                config: value.eatingInteractionConfig,
                factionId: factionId,
                onChanged: (c) => onChanged(_copy(eatingInteractionConfig: c)),
              ),
            if (value.actuatorType == ActuatorType.reserveSlot.value)
              ReserveSlotConfigForm(
                config: value.reserveSlotConfig,
                onChanged: (c) => onChanged(_copy(reserveSlotConfig: c)),
              ),
            if (value.actuatorType == ActuatorType.playAnimation.value)
              PlayAnimationConfigForm(
                config: value.playAnimationConfig,
                factionId: factionId,
                onChanged: (c) => onChanged(_copy(playAnimationConfig: c)),
              ),
          ],
        ),
      ),
    );
  }
}

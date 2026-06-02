import 'package:data_gen_ai/core/enums/interaction_type.dart';
import 'package:data_gen_ai/core/enums/position_type.dart';
import 'package:data_gen_ai/core/enums/sensor_query_mode.dart';
import 'package:data_gen_ai/core/enums/stats_type.dart';
import 'package:data_gen_ai/core/enums/character_faction_tag.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/models/item_category_definition.dart';
import 'package:data_gen_ai/models/query_view/equipment_query_view.dart';
import 'package:data_gen_ai/models/query_view/inventory_query_view.dart';
import 'package:data_gen_ai/models/query_view/notification_query_view.dart';
import 'package:data_gen_ai/models/query_view/positioning_query_view.dart';
import 'package:data_gen_ai/models/query_view/reserved_slot_query_view.dart';
import 'package:data_gen_ai/models/query_view/schedule_query_view.dart';
import 'package:data_gen_ai/models/query_view/self_stats_query_view.dart';
import 'package:data_gen_ai/models/query_view/sensor_agent_query_view.dart';
import 'package:data_gen_ai/models/query_view/sensor_item_query_view.dart';
import 'package:data_gen_ai/models/query_view/threat_advertisement_query_view.dart';
import 'package:data_gen_ai/models/query_view/workpost_query_view.dart';
import 'package:data_gen_ai/models/unity_reference.dart';
import 'package:data_gen_ai/services/registry_catalog_service.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/bool_toggle.dart';
import 'package:data_gen_ai/widgets/forms/enum_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/faction_id_dropdown.dart';
import 'package:data_gen_ai/widgets/forms/flags_enum_checkbox_group.dart';
import 'package:data_gen_ai/widgets/forms/float_field.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
import 'package:data_gen_ai/widgets/forms/item_category_definition_editor.dart';
import 'package:data_gen_ai/widgets/forms/reference_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/forms/vector2_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QueryViewEditorForm extends StatefulWidget {
  const QueryViewEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<QueryViewEditorForm> createState() => _QueryViewEditorFormState();
}

class _QueryViewEditorFormState extends State<QueryViewEditorForm> {
  late String _typeKey;

  @override
  void initState() {
    super.initState();
    _typeKey = queryViewTypeFromIdentifier(
          widget.entry.envelope.editorClassIdentifier,
        ) ??
        '';
  }

  void _merge(Map<String, dynamic> json) {
    widget.onChanged(mergeEntryPayload(widget.entry, json));
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<RegistryCatalogService>();
    final payload = widget.entry.payload;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Query view ($_typeKey)',
          child: _buildBody(context, catalog, payload),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    RegistryCatalogService catalog,
    Map<String, dynamic> payload,
  ) {
    switch (_typeKey) {
      case 'InventoryQueryViewSO':
        final model = InventoryQueryViewModel.fromJson(payload);
        return ItemCategoryDefinitionEditor(
          value: ItemCategoryDefinitionModel.fromJson(model.itemType),
          onChanged: (v) => _merge(
            InventoryQueryViewModel(itemType: v.toJson()).toJson(),
          ),
        );
      case 'EquipmentQueryViewSO':
        final equip = EquipmentQueryViewModel.fromJson(payload);
        return ItemCategoryDefinitionEditor(
          value: ItemCategoryDefinitionModel.fromJson(equip.itemType),
          onChanged: (v) => _merge(
            EquipmentQueryViewModel(itemType: v.toJson()).toJson(),
          ),
        );
      case 'SensorItemQueryViewSO':
        final item = SensorItemQueryViewModel.fromJson(payload);
        return Column(
          children: <Widget>[
            IntField(
              label: 'Item type ID',
              initialValue: item.itemTypeId,
              onChanged: (v) => _merge(
                item
                    .copyWith(itemTypeId: v)
                    .toJson(),
              ),
            ),
            BoolToggle(
              label: 'In line of sight',
              value: item.inLineOfSight,
              onChanged: (v) =>
                  _merge(item.copyWith(inLineOfSight: v).toJson()),
            ),
            EnumDropdown(
              label: 'Mode',
              value: item.averagesOfAll ? 1 : 0,
              options: {
                for (final e in SensorQueryMode.values) e.value: e.name,
              },
              onChanged: (v) => _merge(
                SensorItemQueryViewModel(
                  itemTypeId: item.itemTypeId,
                  inLineOfSight: item.inLineOfSight,
                  averagesOfAll: v == 1,
                  queryInteractionSlot: v == 2,
                  interactionType: item.interactionType,
                  interactionState: item.interactionState,
                ).toJson(),
              ),
            ),
            EnumDropdown(
              label: 'Interaction type',
              value: item.interactionType,
              options: {
                for (final e in InteractionType.values) e.value: e.name,
              },
              onChanged: (v) =>
                  _merge(item.copyWith(interactionType: v).toJson()),
            ),
          ],
        );
      case 'SensorAgentQueryViewSO':
        final agent = SensorAgentQueryViewModel.fromJson(payload);
        return Column(
          children: <Widget>[
            FlagsEnumCheckboxGroup(
              label: 'Faction mask',
              value: agent.factionMask,
              options: {
                for (final e in CharacterFactionTag.values)
                  if (e.value != 0) e.value: e.name,
              },
              onChanged: (v) => _merge(agent.copyWith(factionMask: v).toJson()),
            ),
            FactionIdDropdown(
              catalog: catalog,
              label: 'Agent faction',
              value: agent.agentFaction,
              onChanged: (v) => _merge(agent.copyWith(agentFaction: v).toJson()),
            ),
            BoolToggle(
              label: 'Include friends',
              value: agent.includeFriends,
              onChanged: (v) =>
                  _merge(agent.copyWith(includeFriends: v).toJson()),
            ),
            BoolToggle(
              label: 'Include neutrals',
              value: agent.includeNeutrals,
              onChanged: (v) =>
                  _merge(agent.copyWith(includeNeutrals: v).toJson()),
            ),
            BoolToggle(
              label: 'Include enemies',
              value: agent.includeEnemies,
              onChanged: (v) =>
                  _merge(agent.copyWith(includeEnemies: v).toJson()),
            ),
            BoolToggle(
              label: 'In line of sight',
              value: agent.inLineOfSight,
              onChanged: (v) =>
                  _merge(agent.copyWith(inLineOfSight: v).toJson()),
            ),
            EnumDropdown(
              label: 'Mode',
              value: agent.mode,
              options: {
                for (final e in SensorQueryMode.values) e.value: e.name,
              },
              onChanged: (v) => _merge(agent.copyWith(mode: v).toJson()),
            ),
            if (agent.mode == SensorQueryMode.average.value)
              IntField(
                label: 'Perceived power aggregation',
                initialValue: agent.perceivedPowerAggregation,
                onChanged: (v) => _merge(
                  agent.copyWith(perceivedPowerAggregation: v).toJson(),
                ),
              ),
            if (agent.mode == SensorQueryMode.interactionSlot.value)
              EnumDropdown(
                label: 'Interaction type',
                value: agent.interactionType,
                options: {
                  for (final e in InteractionType.values) e.value: e.name,
                },
                onChanged: (v) =>
                    _merge(agent.copyWith(interactionType: v).toJson()),
              ),
            if (agent.mode == SensorQueryMode.notification.value)
              EnumDropdown(
                label: 'Notification filter',
                value: agent.notificationFilter,
                options: {
                  for (final e in NotificationType.values) e.value: e.name,
                },
                onChanged: (v) =>
                    _merge(agent.copyWith(notificationFilter: v).toJson()),
              ),
          ],
        );
      case 'SelfStatsQueryViewSO':
        final self = SelfStatsQueryViewModel.fromJson(payload);
        return EnumDropdown(
          label: 'Stats type',
          value: self.type,
          options: {for (final e in StatsType.values) e.value: e.name},
          onChanged: (v) => _merge(SelfStatsQueryViewModel(type: v).toJson()),
        );
      case 'SensorPositioningQueryViewSO':
        final pos = PositioningQueryViewModel.fromJson(payload);
        return Column(
          children: <Widget>[
            EnumDropdown(
              label: 'Position type',
              value: pos.positionType,
              options: {for (final e in PositionType.values) e.value: e.name},
              onChanged: (v) => _merge(
                PositioningQueryViewModel(
                  positionType: v,
                  temperatureRange: pos.temperatureRange,
                ).toJson(),
              ),
            ),
            if (pos.positionType == PositionType.specialTemperature.value)
              Vector2Field(
                label: 'Temperature range',
                value: pos.temperatureRange,
                onChanged: (v) => _merge(
                  PositioningQueryViewModel(
                    positionType: pos.positionType,
                    temperatureRange: v,
                  ).toJson(),
                ),
              ),
          ],
        );
      case 'ThreatAdvertisementQueryViewSO':
        final threat = ThreatAdvertisementQueryViewModel.fromJson(payload);
        return Column(
          children: <Widget>[
            FloatField(
              label: 'Range',
              initialValue: threat.range,
              onChanged: (v) => _merge(threat.copyWith(range: v).toJson()),
            ),
            IntField(
              label: 'Threat type',
              initialValue: threat.threatType,
              onChanged: (v) => _merge(threat.copyWith(threatType: v).toJson()),
            ),
          ],
        );
      case 'NotificationQueryViewSO':
        final notif = NotificationQueryViewModel.fromJson(payload);
        return Column(
          children: <Widget>[
            FlagsEnumCheckboxGroup(
              label: 'Faction mask',
              value: notif.factionMask,
              options: {
                for (final e in CharacterFactionTag.values)
                  if (e.value != 0) e.value: e.name,
              },
              onChanged: (v) => _merge(notif.copyWith(factionMask: v).toJson()),
            ),
            FactionIdDropdown(
              catalog: catalog,
              label: 'Agent faction',
              value: notif.agentFaction,
              onChanged: (v) => _merge(notif.copyWith(agentFaction: v).toJson()),
            ),
            BoolToggle(
              label: 'In line of sight',
              value: notif.inLineOfSight,
              onChanged: (v) =>
                  _merge(notif.copyWith(inLineOfSight: v).toJson()),
            ),
            EnumDropdown(
              label: 'Notification filter',
              value: notif.notificationFilter,
              options: {
                for (final e in NotificationType.values) e.value: e.name,
              },
              onChanged: (v) =>
                  _merge(notif.copyWith(notificationFilter: v).toJson()),
            ),
          ],
        );
      case 'ReservedSlotQueryViewSO':
        final slot = ReservedSlotQueryViewModel.fromJson(payload);
        return EnumDropdown(
          label: 'Filter',
          value: slot.filter,
          options: {for (final e in InteractionType.values) e.value: e.name},
          onChanged: (v) => _merge(ReservedSlotQueryViewModel(filter: v).toJson()),
        );
      case 'ScheduleQueryViewSO':
        final sched = ScheduleQueryViewModel.fromJson(payload);
        return Column(
          children: <Widget>[
            ReferenceField(
              label: 'Schedule asset',
              reference: sched.schedule,
              onGuidChanged: (guid) => _merge(
                sched
                    .copyWith(
                      schedule: UnityReference(
                        guid: guid,
                        fileId: guid.isEmpty ? 0 : 11400000,
                      ),
                    )
                    .toJson(),
              ),
            ),
            TextFormField(
              initialValue: sched.pointGroup,
              decoration: const InputDecoration(labelText: 'Point group'),
              onChanged: (v) =>
                  _merge(sched.copyWith(pointGroup: v).toJson()),
            ),
            IntField(
              label: 'Point index',
              initialValue: sched.pointIndex,
              onChanged: (v) => _merge(sched.copyWith(pointIndex: v).toJson()),
            ),
          ],
        );
      case 'WorkpostQueryViewSO':
        final work = WorkpostQueryViewModel.fromJson(payload);
        return Column(
          children: <Widget>[
            ReferenceField(
              label: 'Work types config',
              reference: work.workTypes,
              onGuidChanged: (guid) => _merge(
                work
                    .copyWith(
                      workTypes: UnityReference(
                        guid: guid,
                        fileId: guid.isEmpty ? 0 : 11400000,
                      ),
                    )
                    .toJson(),
              ),
            ),
            IntField(
              label: 'Type filter bit index',
              initialValue: work.typeFilterBitIndex,
              onChanged: (v) =>
                  _merge(work.copyWith(typeFilterBitIndex: v).toJson()),
            ),
            IntField(
              label: 'Variant filter',
              initialValue: work.variantFilter,
              onChanged: (v) => _merge(work.copyWith(variantFilter: v).toJson()),
            ),
            IntField(
              label: 'Min priority',
              initialValue: work.minPriority,
              onChanged: (v) => _merge(work.copyWith(minPriority: v).toJson()),
            ),
            FloatField(
              label: 'Max range',
              initialValue: work.maxRange,
              onChanged: (v) => _merge(work.copyWith(maxRange: v).toJson()),
            ),
            BoolToggle(
              label: 'Unassigned only',
              value: work.unassignedOnly,
              onChanged: (v) =>
                  _merge(work.copyWith(unassignedOnly: v).toJson()),
            ),
          ],
        );
      default:
        return Text('Unsupported query type: $_typeKey');
    }
  }
}

extension on SensorItemQueryViewModel {
  SensorItemQueryViewModel copyWith({
    int? itemTypeId,
    bool? inLineOfSight,
    bool? averagesOfAll,
    bool? queryInteractionSlot,
    int? interactionType,
    int? interactionState,
  }) {
    return SensorItemQueryViewModel(
      itemTypeId: itemTypeId ?? this.itemTypeId,
      inLineOfSight: inLineOfSight ?? this.inLineOfSight,
      averagesOfAll: averagesOfAll ?? this.averagesOfAll,
      queryInteractionSlot: queryInteractionSlot ?? this.queryInteractionSlot,
      interactionType: interactionType ?? this.interactionType,
      interactionState: interactionState ?? this.interactionState,
    );
  }
}

extension on ThreatAdvertisementQueryViewModel {
  ThreatAdvertisementQueryViewModel copyWith({double? range, int? threatType}) {
    return ThreatAdvertisementQueryViewModel(
      range: range ?? this.range,
      threatType: threatType ?? this.threatType,
    );
  }
}

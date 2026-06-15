import 'package:data_gen_ai/graph_editor/registry/node_registry.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_cubit.dart';
import 'package:data_gen_ai/graph_editor/state/graph_editor_state.dart';
import 'package:data_gen_ai/graph_editor/ui/widgets/string_dropdown_field.dart';
import 'package:data_gen_ai/widgets/forms/bool_toggle.dart';
import 'package:data_gen_ai/widgets/forms/float_field.dart';
import 'package:data_gen_ai/widgets/forms/int_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NodeOptionsPanel extends StatelessWidget {
  const NodeOptionsPanel({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GraphEditorCubit, GraphEditorState>(
      builder: (context, state) {
        final selectedNode = state.selectedNode;
        if (selectedNode == null) {
          return const _EmptyPanel(
            message: 'Select a node to edit its options.',
          );
        }

        final definition = NodeRegistry.byTypeId(selectedNode.type);
        return _OptionsScaffold(
          title: definition?.displayName ?? 'Node',
          subtitle: definition?.description,
          scrollController: scrollController,
          child: _NodeOptionsEditor(node: selectedNode),
        );
      },
    );
  }
}

class _OptionsScaffold extends StatelessWidget {
  const _OptionsScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    this.scrollController,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _NodeOptionsEditor extends StatelessWidget {
  const _NodeOptionsEditor({required this.node});

  final dynamic node;

  @override
  Widget build(BuildContext context) {
    return switch (node.type) {
      CharacterDesignNodeTypes.sensedAgentQueryNode =>
        _SensedAgentQueryOptions(node: node),
      CharacterDesignNodeTypes.actionableNode => _ActionableOptions(node: node),
      CharacterDesignNodeTypes.actuatorNode => _ActuatorOptions(node: node),
      CharacterDesignNodeTypes.characterProfileNode =>
        _ProfileOptions(node: node),
      _ => const _EmptyPanel(message: 'No options for this node type yet.'),
    };
  }
}

class _SensedAgentQueryOptions extends StatelessWidget {
  const _SensedAgentQueryOptions({required this.node});

  final dynamic node;

  Map<String, dynamic> get _query =>
      Map<String, dynamic>.from(node.options['Query'] as Map? ?? const {});

  void _update(BuildContext context, String key, dynamic value) {
    final options = Map<String, dynamic>.from(node.options);
    final query = Map<String, dynamic>.from(_query)..[key] = value;
    options['Query'] = query;
    context.read<GraphEditorCubit>().updateNodeOptions(node.id, options);
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Query',
      subtitle: 'Sensed agent filter settings',
      child: Column(
        children: <Widget>[
          IntField(
            label: 'Agent Faction',
            initialValue: (_query['AgentFaction'] as num?)?.toInt() ?? 0,
            onChanged: (v) => _update(context, 'AgentFaction', v),
          ),
          BoolToggle(
            label: 'Include Friends',
            value: _query['IncludeFriends'] as bool? ?? false,
            onChanged: (v) => _update(context, 'IncludeFriends', v),
          ),
          BoolToggle(
            label: 'Include Neutrals',
            value: _query['IncludeNeutrals'] as bool? ?? false,
            onChanged: (v) => _update(context, 'IncludeNeutrals', v),
          ),
          BoolToggle(
            label: 'Include Enemies',
            value: _query['IncludeEnemies'] as bool? ?? true,
            onChanged: (v) => _update(context, 'IncludeEnemies', v),
          ),
          BoolToggle(
            label: 'In Line Of Sight',
            value: _query['InLineOfSight'] as bool? ?? true,
            onChanged: (v) => _update(context, 'InLineOfSight', v),
          ),
          StringDropdownField(
            label: 'Mode',
            value: _query['Mode'] as String? ?? 'Nearest',
            options: const <String>[
              'Nearest',
              'Farthest',
              'Random',
              'HighestPerceivedPower',
            ],
            onChanged: (v) => _update(context, 'Mode', v),
          ),
          StringDropdownField(
            label: 'Perceived Power Aggregation',
            value: _query['PerceivedPowerAggregation'] as String? ?? 'Average',
            options: const <String>['Average', 'Max', 'Min', 'Sum'],
            onChanged: (v) => _update(context, 'PerceivedPowerAggregation', v),
          ),
          IntField(
            label: 'Trespass Zones',
            initialValue: (_query['TrespassZones'] as num?)?.toInt() ?? 0,
            onChanged: (v) => _update(context, 'TrespassZones', v),
          ),
        ],
      ),
    );
  }
}

class _ActionableOptions extends StatelessWidget {
  const _ActionableOptions({required this.node});

  final dynamic node;

  Map<String, dynamic> get _actionable => Map<String, dynamic>.from(
    node.options['Actionable'] as Map? ?? const {},
  );

  void _update(BuildContext context, String key, dynamic value) {
    final options = Map<String, dynamic>.from(node.options);
    final actionable = Map<String, dynamic>.from(_actionable)..[key] = value;
    options['Actionable'] = actionable;
    context.read<GraphEditorCubit>().updateNodeOptions(node.id, options);
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Actionable',
      subtitle: 'Cost and time configuration',
      child: Column(
        children: <Widget>[
          FloatField(
            label: 'Const Cost',
            initialValue: (_actionable['ConstCost'] as num?)?.toDouble() ?? 0,
            onChanged: (v) => _update(context, 'ConstCost', v),
          ),
          FloatField(
            label: 'Cost Field Multiplier',
            initialValue:
                (_actionable['CostFieldMultiplier'] as num?)?.toDouble() ?? 1,
            onChanged: (v) => _update(context, 'CostFieldMultiplier', v),
          ),
          FloatField(
            label: 'Const Time',
            initialValue: (_actionable['ConstTime'] as num?)?.toDouble() ?? 0,
            onChanged: (v) => _update(context, 'ConstTime', v),
          ),
          FloatField(
            label: 'Time Field Multiplier',
            initialValue:
                (_actionable['TimeFieldMultiplier'] as num?)?.toDouble() ?? 1,
            onChanged: (v) => _update(context, 'TimeFieldMultiplier', v),
          ),
        ],
      ),
    );
  }
}

class _ActuatorOptions extends StatelessWidget {
  const _ActuatorOptions({required this.node});

  final dynamic node;

  void _updateType(BuildContext context, String value) {
    final options = Map<String, dynamic>.from(node.options)
      ..['ActuatorType'] = value;
    context.read<GraphEditorCubit>().updateNodeOptions(node.id, options);
  }

  @override
  Widget build(BuildContext context) {
    final actuatorType =
        node.options['ActuatorType'] as String? ?? 'NavigateToPosition';
    return SectionCard(
      title: 'Actuator',
      subtitle: 'Execution strategy for paired actionable',
      child: StringDropdownField(
        label: 'Actuator Type',
        value: actuatorType,
        options: const <String>[
          'NavigateToPosition',
          'Wait',
          'Eat',
          'ReserveSlot',
          'PlayAnimation',
          'Block',
          'Flee',
          'FollowSchedule',
        ],
        onChanged: (v) => _updateType(context, v),
      ),
    );
  }
}

class _ProfileOptions extends StatelessWidget {
  const _ProfileOptions({required this.node});

  final dynamic node;

  Map<String, dynamic> get _profile =>
      Map<String, dynamic>.from(node.options['Profile'] as Map? ?? const {});

  void _update(BuildContext context, String key, dynamic value) {
    final options = Map<String, dynamic>.from(node.options);
    final profile = Map<String, dynamic>.from(_profile)..[key] = value;
    options['Profile'] = profile;
    context.read<GraphEditorCubit>().updateNodeOptions(node.id, options);
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Profile',
      subtitle: 'Character variant profile settings',
      child: Column(
        children: <Widget>[
          BoolToggle(
            label: 'Is Beast',
            value: _profile['IsBeast'] as bool? ?? false,
            onChanged: (v) => _update(context, 'IsBeast', v),
          ),
          IntField(
            label: 'Default Action',
            initialValue: (_profile['DefaultAction'] as num?)?.toInt() ?? -1,
            onChanged: (v) => _update(context, 'DefaultAction', v),
          ),
          BoolToggle(
            label: 'Enable Voice Events',
            value: _profile['EnableVoiceEvents'] as bool? ?? false,
            onChanged: (v) => _update(context, 'EnableVoiceEvents', v),
          ),
          IntField(
            label: 'Voice Emit Mask',
            initialValue: (_profile['VoiceEmitMask'] as num?)?.toInt() ?? 1,
            onChanged: (v) => _update(context, 'VoiceEmitMask', v),
          ),
          IntField(
            label: 'Voice Listen Mask',
            initialValue: (_profile['VoiceListenMask'] as num?)?.toInt() ?? 1,
            onChanged: (v) => _update(context, 'VoiceListenMask', v),
          ),
          BoolToggle(
            label: 'Provide Workpost Holder',
            value: _profile['ProvideWorkpostHolder'] as bool? ?? false,
            onChanged: (v) => _update(context, 'ProvideWorkpostHolder', v),
          ),
        ],
      ),
    );
  }
}

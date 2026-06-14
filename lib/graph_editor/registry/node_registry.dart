import 'dart:ui';

import 'package:data_gen_ai/graph_editor/models/port_definition.dart';
import 'package:data_gen_ai/graph_editor/models/port_type.dart';

typedef PortsResolver = List<PortDefinition> Function(Map<String, dynamic> options);

class NodeTypeDefinition {
  const NodeTypeDefinition({
    required this.typeId,
    required this.displayName,
    required this.category,
    required this.accentColor,
    required this.ports,
    this.description,
    this.isContextNode = false,
    this.isBlockNode = false,
    this.parentContextTypeId,
    this.portsResolver,
    this.defaultOptions = const <String, dynamic>{},
  });

  final String typeId;
  final String displayName;
  final String category;
  final Color accentColor;
  final String? description;
  final bool isContextNode;
  final bool isBlockNode;
  final String? parentContextTypeId;
  final List<PortDefinition> ports;
  final PortsResolver? portsResolver;
  final Map<String, dynamic> defaultOptions;

  List<PortDefinition> resolvePorts(Map<String, dynamic> options) {
    if (portsResolver != null) {
      return portsResolver!(options);
    }
    return ports;
  }

  PortDefinition? portByName(
    String portName,
    Map<String, dynamic> options,
  ) {
    for (final port in resolvePorts(options)) {
      if (port.name == portName) return port;
    }
    return null;
  }
}

abstract final class CharacterDesignNodeTypes {
  static const characterDefinition =
      'AI.Editor.CharacterDesignGraph.Nodes.CharacterDefinition';
  static const characterVariantBlock =
      'AI.Editor.CharacterDesignGraph.Nodes.CharacterVariantBlock';
  static const characterProfileNode =
      'AI.Editor.CharacterDesignGraph.Nodes.CharacterProfileNode';
  static const characterPerceptionBlock =
      'AI.Editor.CharacterDesignGraph.Nodes.CharacterPerceptionBlock';
  static const beastManipulationOptionBlock =
      'AI.Editor.CharacterDesignGraph.Nodes.BeastManipulationOptionBlock';
  static const sensedAgentQueryNode =
      'AI.Editor.CharacterDesignGraph.Nodes.Queries.SensedAgentQueryNode';
  static const beliefNode = 'AI.Editor.CharacterDesignGraph.Nodes.BeliefNode';
  static const beliefSelectionNode =
      'AI.Editor.CharacterDesignGraph.Nodes.BeliefSelectionNode';
  static const considerationFunction =
      'AI.Editor.CharacterDesignGraph.Nodes.ConsiderationFunction';
  static const actionableNode =
      'AI.Editor.CharacterDesignGraph.Nodes.ActionableNode';
  static const actuatorNode =
      'AI.Editor.CharacterDesignGraph.Nodes.ActuatorNode';
}

abstract final class NodeRegistry {
  static final List<NodeTypeDefinition> all = <NodeTypeDefinition>[
    _characterDefinition,
    _characterVariantBlock,
    _characterProfileNode,
    _characterPerceptionBlock,
    _beastManipulationOptionBlock,
    _sensedAgentQueryNode,
    _beliefNode,
    _beliefSelectionNode,
    _considerationFunction,
    _actionableNode,
    _actuatorNode,
  ];

  static final Map<String, NodeTypeDefinition> _byId = {
    for (final def in all) def.typeId: def,
  };

  static NodeTypeDefinition? byTypeId(String typeId) => _byId[typeId];

  static List<NodeTypeDefinition> paletteNodes() =>
      all.where((d) => !d.isBlockNode).toList();

  static List<NodeTypeDefinition> blocksForContext(String contextTypeId) =>
      all
          .where(
            (d) => d.isBlockNode && d.parentContextTypeId == contextTypeId,
          )
          .toList();

  static const _characterDefinition = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.characterDefinition,
    displayName: 'Character',
    category: 'Character',
    description: 'Root character authoring context',
    accentColor: Color(0xFF389973),
    isContextNode: true,
    ports: <PortDefinition>[],
  );

  static const _characterVariantBlock = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.characterVariantBlock,
    displayName: 'Character Variant',
    category: 'Character',
    description: 'Named variant with profile, beliefs, and actions',
    accentColor: Color(0xFF4A9E82),
    isBlockNode: true,
    parentContextTypeId: CharacterDesignNodeTypes.characterDefinition,
    ports: <PortDefinition>[
      PortDefinition(
        name: 'Variant Name',
        direction: PortDirection.input,
        type: PortType.string,
      ),
      PortDefinition(
        name: 'Profile',
        direction: PortDirection.input,
        type: PortType.characterProfileGraphData,
      ),
      PortDefinition(
        name: 'Belief Selections',
        direction: PortDirection.input,
        type: PortType.beliefSelection,
        multiCapacity: true,
      ),
      PortDefinition(
        name: 'Actionables',
        direction: PortDirection.input,
        type: PortType.actionable,
        multiCapacity: true,
      ),
      PortDefinition(
        name: 'Actuators',
        direction: PortDirection.input,
        type: PortType.graphActuatorRef,
        multiCapacity: true,
      ),
    ],
  );

  static const _characterProfileNode = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.characterProfileNode,
    displayName: 'Profile',
    category: 'Character',
    description: 'Stats, perception, beast options, voice masks',
    accentColor: Color(0xFF597AB8),
    isContextNode: true,
    defaultOptions: <String, dynamic>{
      'Profile': <String, dynamic>{
        'IsBeast': false,
        'DefaultAction': -1,
        'EnableVoiceEvents': false,
        'VoiceEmitMask': 1,
        'VoiceListenMask': 1,
        'VoiceLODOverride': -1,
        'ProvideWorkpostHolder': false,
      },
    },
    ports: <PortDefinition>[
      PortDefinition(
        name: 'Profile',
        direction: PortDirection.output,
        type: PortType.characterProfileGraphData,
      ),
    ],
  );

  static const _characterPerceptionBlock = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.characterPerceptionBlock,
    displayName: 'Perception',
    category: 'Character',
    accentColor: Color(0xFF6B8BC4),
    isBlockNode: true,
    parentContextTypeId: CharacterDesignNodeTypes.characterProfileNode,
    ports: <PortDefinition>[
      PortDefinition(
        name: 'Faction',
        direction: PortDirection.input,
        type: PortType.intType,
      ),
      PortDefinition(
        name: 'Tags',
        direction: PortDirection.input,
        type: PortType.characterFactionTag,
      ),
      PortDefinition(
        name: 'Perceived Power',
        direction: PortDirection.input,
        type: PortType.floatType,
      ),
      PortDefinition(
        name: 'Allowed Zones',
        direction: PortDirection.input,
        type: PortType.intType,
      ),
    ],
  );

  static const _beastManipulationOptionBlock = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.beastManipulationOptionBlock,
    displayName: 'Beast Option',
    category: 'Character',
    accentColor: Color(0xFF7A94CC),
    isBlockNode: true,
    parentContextTypeId: CharacterDesignNodeTypes.characterProfileNode,
    ports: <PortDefinition>[
      PortDefinition(
        name: 'Label',
        direction: PortDirection.input,
        type: PortType.string,
      ),
      PortDefinition(
        name: 'Stat',
        direction: PortDirection.input,
        type: PortType.beastVariableStat,
      ),
      PortDefinition(
        name: 'Mode',
        direction: PortDirection.input,
        type: PortType.beastStatModifyMode,
      ),
      PortDefinition(
        name: 'Value',
        direction: PortDirection.input,
        type: PortType.floatType,
      ),
    ],
  );

  static const _sensedAgentQueryNode = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.sensedAgentQueryNode,
    displayName: 'Sensed Agent Query',
    category: 'Queries',
    accentColor: Color(0xFF8B6BB5),
    defaultOptions: <String, dynamic>{
      'Query': <String, dynamic>{
        'AgentFaction': 0,
        'IncludeFriends': false,
        'IncludeNeutrals': false,
        'IncludeEnemies': true,
        'InLineOfSight': true,
        'Mode': 'Nearest',
        'PerceivedPowerAggregation': 'Average',
        'InteractionType': 'None',
        'NotificationFilter': 'None',
        'TrespassZones': 0,
      },
    },
    ports: <PortDefinition>[
      PortDefinition(
        name: 'Query',
        direction: PortDirection.output,
        type: PortType.graphQueryRef,
      ),
    ],
  );

  static const _beliefNode = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.beliefNode,
    displayName: 'Belief',
    category: 'Utility AI',
    accentColor: Color(0xFFB57A4A),
    ports: <PortDefinition>[
      PortDefinition(
        name: 'Query',
        direction: PortDirection.input,
        type: PortType.graphQueryRef,
      ),
      PortDefinition(
        name: 'ResultField',
        direction: PortDirection.input,
        type: PortType.utilityAIResultField,
      ),
      PortDefinition(
        name: 'BeliefCondition',
        direction: PortDirection.input,
        type: PortType.beliefCondition,
      ),
      PortDefinition(
        name: 'Target Value',
        direction: PortDirection.input,
        type: PortType.utilityAIValue,
      ),
      PortDefinition(
        name: 'UseHysteresis',
        direction: PortDirection.input,
        type: PortType.boolType,
      ),
      PortDefinition(
        name: 'HysteresisValue',
        direction: PortDirection.input,
        type: PortType.floatType,
      ),
      PortDefinition(
        name: 'Belief',
        direction: PortDirection.output,
        type: PortType.belief,
      ),
    ],
  );

  static const _beliefSelectionNode = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.beliefSelectionNode,
    displayName: 'Belief Selection',
    category: 'Utility AI',
    accentColor: Color(0xFFC48A5A),
    isContextNode: true,
    ports: <PortDefinition>[
      PortDefinition(
        name: 'Selected Belief',
        direction: PortDirection.input,
        type: PortType.belief,
      ),
      PortDefinition(
        name: 'Belief Selection',
        direction: PortDirection.output,
        type: PortType.beliefSelection,
      ),
    ],
  );

  static const _considerationFunction = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.considerationFunction,
    displayName: 'Consideration Function',
    category: 'Utility AI',
    accentColor: Color(0xFFD49A6A),
    isBlockNode: true,
    parentContextTypeId: CharacterDesignNodeTypes.beliefSelectionNode,
    ports: <PortDefinition>[
      PortDefinition(
        name: 'Considerable',
        direction: PortDirection.input,
        type: PortType.considerable,
      ),
      PortDefinition(
        name: 'Function',
        direction: PortDirection.input,
        type: PortType.considerationFunctionData,
      ),
    ],
  );

  static const _actionableNode = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.actionableNode,
    displayName: 'Actionable',
    category: 'GOAP',
    accentColor: Color(0xFF4A8AB5),
    defaultOptions: <String, dynamic>{
      'Actionable': <String, dynamic>{
        'ConstCost': 0,
        'CostFieldMultiplier': 1,
        'ConstTime': 0,
        'TimeFieldMultiplier': 1,
      },
    },
    ports: <PortDefinition>[
      PortDefinition(
        name: 'Action Id',
        direction: PortDirection.input,
        type: PortType.intType,
      ),
      PortDefinition(
        name: 'Required Beliefs',
        direction: PortDirection.input,
        type: PortType.belief,
        multiCapacity: true,
      ),
      PortDefinition(
        name: 'Provided Beliefs',
        direction: PortDirection.input,
        type: PortType.belief,
        multiCapacity: true,
      ),
      PortDefinition(
        name: 'Cost Query',
        direction: PortDirection.input,
        type: PortType.graphQueryRef,
      ),
      PortDefinition(
        name: 'Time Query',
        direction: PortDirection.input,
        type: PortType.graphQueryRef,
      ),
      PortDefinition(
        name: 'Actionable',
        direction: PortDirection.output,
        type: PortType.actionable,
      ),
    ],
  );

  static final _actuatorNode = NodeTypeDefinition(
    typeId: CharacterDesignNodeTypes.actuatorNode,
    displayName: 'Actuator',
    category: 'GOAP',
    accentColor: Color(0xFF5A9AC5),
    defaultOptions: <String, dynamic>{'ActuatorType': 'NavigateToPosition'},
    portsResolver: _resolveActuatorPorts,
    ports: const <PortDefinition>[
      PortDefinition(
        name: 'Action Id',
        direction: PortDirection.input,
        type: PortType.intType,
      ),
      PortDefinition(
        name: 'Avatar Mask',
        direction: PortDirection.input,
        type: PortType.avatarMask,
      ),
      PortDefinition(
        name: 'Actuator',
        direction: PortDirection.output,
        type: PortType.graphActuatorRef,
      ),
    ],
  );

  static List<PortDefinition> _resolveActuatorPorts(
    Map<String, dynamic> options,
  ) {
    final actuatorType = options['ActuatorType'] as String? ?? 'NavigateToPosition';
    final ports = <PortDefinition>[
      const PortDefinition(
        name: 'Action Id',
        direction: PortDirection.input,
        type: PortType.intType,
      ),
      const PortDefinition(
        name: 'Avatar Mask',
        direction: PortDirection.input,
        type: PortType.avatarMask,
      ),
      ..._actuatorTypePorts(actuatorType),
      const PortDefinition(
        name: 'Actuator',
        direction: PortDirection.output,
        type: PortType.graphActuatorRef,
      ),
    ];
    return ports;
  }

  static List<PortDefinition> _actuatorTypePorts(String actuatorType) {
    return switch (actuatorType) {
      'NavigateToPosition' => const <PortDefinition>[
        PortDefinition(
          name: 'Target Query',
          direction: PortDirection.input,
          type: PortType.graphQueryRef,
        ),
        PortDefinition(
          name: 'Result Field',
          direction: PortDirection.input,
          type: PortType.utilityAIResultField,
        ),
        PortDefinition(
          name: 'Stopping Distance',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Track Moving Target',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Destination Update Interval',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Complete On Arrival',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Speed Multiplier',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Use Direct Movement Input',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
      ],
      'Wait' => const <PortDefinition>[
        PortDefinition(
          name: 'Duration',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Stop Navigation',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Wait Animation',
          direction: PortDirection.input,
          type: PortType.intType,
        ),
      ],
      'Eat' => const <PortDefinition>[
        PortDefinition(
          name: 'Slot Query',
          direction: PortDirection.input,
          type: PortType.graphQueryRef,
        ),
        PortDefinition(
          name: 'Result Field',
          direction: PortDirection.input,
          type: PortType.utilityAIResultField,
        ),
        PortDefinition(
          name: 'Approach Stopping Distance',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Snap Stopping Distance',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Speed Multiplier',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Track Moving Target',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Destination Update Interval',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Use Direct Movement Input',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Satiety Increase Per Second',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Animation',
          direction: PortDirection.input,
          type: PortType.intType,
        ),
      ],
      'ReserveSlot' => const <PortDefinition>[
        PortDefinition(
          name: 'Slot Query',
          direction: PortDirection.input,
          type: PortType.graphQueryRef,
        ),
        PortDefinition(
          name: 'Result Field',
          direction: PortDirection.input,
          type: PortType.utilityAIResultField,
        ),
        PortDefinition(
          name: 'Filter',
          direction: PortDirection.input,
          type: PortType.interactionType,
        ),
      ],
      'PlayAnimation' => const <PortDefinition>[
        PortDefinition(
          name: 'Animation',
          direction: PortDirection.input,
          type: PortType.intType,
        ),
        PortDefinition(
          name: 'Loop',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Duration',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Complete On Duration',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Prevent Interruption',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Lock Movement',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Enable Hitboxes',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Hitbox Start Time',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Hitbox End Time',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Hit Power',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Hit Cooldown',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Allow Friendly Fire',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Cooldown Per Attack Instance',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
      ],
      'Block' => const <PortDefinition>[
        PortDefinition(
          name: 'Threat Query',
          direction: PortDirection.input,
          type: PortType.graphQueryRef,
        ),
        PortDefinition(
          name: 'Result Field',
          direction: PortDirection.input,
          type: PortType.utilityAIResultField,
        ),
        PortDefinition(
          name: 'Duration',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Stop Navigation',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Block Animation',
          direction: PortDirection.input,
          type: PortType.intType,
        ),
        PortDefinition(
          name: 'Clear Notification On Exit',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Base Urgency',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Distance Urgency Weight',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Distance Falloff Max',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Vitality Urgency Weight',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Vitality Reference',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Urgency Clamp Max',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
      ],
      'Flee' => const <PortDefinition>[
        PortDefinition(
          name: 'Threat Query',
          direction: PortDirection.input,
          type: PortType.graphQueryRef,
        ),
        PortDefinition(
          name: 'Safe Distance',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Sprint Multiplier',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Escape Destination Offset',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Use Direct Movement Input',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Avoid Obstacles With Raycast',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
        PortDefinition(
          name: 'Obstacle Raycast Length',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
      ],
      'FollowSchedule' => const <PortDefinition>[
        PortDefinition(
          name: 'Schedule Query',
          direction: PortDirection.input,
          type: PortType.graphQueryRef,
        ),
        PortDefinition(
          name: 'Arrival Distance',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Speed Multiplier',
          direction: PortDirection.input,
          type: PortType.floatType,
        ),
        PortDefinition(
          name: 'Loop',
          direction: PortDirection.input,
          type: PortType.boolType,
        ),
      ],
      _ => const <PortDefinition>[],
    };
  }
}

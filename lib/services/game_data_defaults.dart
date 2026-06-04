import 'package:data_gen_ai/core/query_view_types.dart';

/// Default Unity JSON payloads for newly created assets.
abstract final class GameDataDefaults {
  static Map<String, dynamic> payloadFor(
    String typeKey, {
    String? queryViewTypeKey,
  }) {
    if (queryViewTypeKey != null) {
      return _queryPayload(queryViewTypeKey);
    }
    switch (typeKey) {
      case 'BeliefSO':
        return <String, dynamic>{
          'queryViewAsset': <String, dynamic>{'fileID': 0},
          'field': 0,
          'condition': 0,
          'isVectorValue': 0,
          'isRangeValue': 0,
          'intValue': 0,
          'boolValue': 0,
          'floatValue': 0,
          'vectorValue': <String, dynamic>{'x': 0, 'y': 0, 'z': 0},
          'rangeValue': <String, dynamic>{'x': 0, 'y': 0},
          'useHysteresis': 0,
          'hysteresisDelta': 0,
        };
      case 'BeliefSelectionSO':
        return <String, dynamic>{
          'belief': <String, dynamic>{'fileID': 0},
          'considerables': <dynamic>[],
        };
      case 'ConsiderableSO':
        return <String, dynamic>{
          'Config': <String, dynamic>{
            'defaultValue': 0,
            'minValue': <String, dynamic>{
              'Float3Value': <String, dynamic>{'x': 0, 'y': 0, 'z': 0},
              'IsVector': 0,
              'IsRange': 0,
            },
            'maxValue': <String, dynamic>{
              'Float3Value': <String, dynamic>{'x': 100, 'y': 0, 'z': 0},
              'IsVector': 0,
              'IsRange': 0,
            },
            'queryInput': <String, dynamic>{'fileID': 0},
            'field': 0,
          },
        };
      case 'ActionableSO':
        return <String, dynamic>{
          'providedBeliefAssets': <dynamic>[],
          'action': 0,
          'requiredBeliefAssets': <dynamic>[],
          'ConstCost': 0,
          'CostQuery': <String, dynamic>{'fileID': 0},
          'CostField': 0,
          'CostFieldMultiplier': 0,
          'ConstTime': 0,
          'TimeQuery': <String, dynamic>{'fileID': 0},
          'TimeField': 0,
          'TimeFieldMultiplier': 0,
        };
      case 'AnimationTypesConfig':
        return <String, dynamic>{
          'types': <dynamic>[],
        };
      default:
        return <String, dynamic>{};
    }
  }

  static Map<String, dynamic> _queryPayload(String queryViewTypeKey) {
    switch (queryViewTypeKey) {
      case 'SensorItemQueryViewSO':
        return <String, dynamic>{
          'itemTypeId': 0,
          'inLineOfSight': 0,
          'mode': 0,
          'interactionType': 0,
        };
      case 'SensorAgentQueryViewSO':
        return <String, dynamic>{
          'factionMask': 0,
          'agentFaction': 0,
          'includeFriends': 0,
          'includeNeutrals': 0,
          'includeEnemies': 0,
          'inLineOfSight': 0,
          'mode': 0,
        };
      case 'SelfStatsQueryViewSO':
        return <String, dynamic>{'statsType': 0};
      case 'WorkpostQueryViewSO':
        return <String, dynamic>{'workTypeId': 0};
      case 'NotificationQueryViewSO':
        return <String, dynamic>{'notificationType': 0};
      case 'PositioningQueryViewSO':
        return <String, dynamic>{'positionType': 0};
      default:
        return <String, dynamic>{};
    }
  }

  static String defaultFolderFor(String typeKey) {
    switch (typeKey) {
      case 'BeliefSO':
        return 'beliefs';
      case 'BeliefSelectionSO':
        return 'belief selection';
      case 'ConsiderableSO':
        return 'considerables';
      case 'BaseQueryViewSO':
        return 'queries';
      case 'AnimationTypesConfig':
        return 'Animations';
      case 'ActionableSO':
        return 'actionable';
      default:
        return '';
    }
  }
}

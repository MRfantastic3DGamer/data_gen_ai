import 'package:data_gen_ai/models/character_stats_so.dart';
import 'package:data_gen_ai/models/game_data_file_entry.dart';
import 'package:data_gen_ai/widgets/editors/so_editor_utils.dart';
import 'package:data_gen_ai/widgets/forms/float_field.dart';
import 'package:data_gen_ai/widgets/forms/section_card.dart';
import 'package:data_gen_ai/widgets/forms/vector2_field.dart';
import 'package:flutter/material.dart';

class CharacterStatsSOEditorForm extends StatefulWidget {
  const CharacterStatsSOEditorForm({
    super.key,
    required this.entry,
    required this.onChanged,
  });

  final GameDataFileEntry entry;
  final ValueChanged<GameDataFileEntry> onChanged;

  @override
  State<CharacterStatsSOEditorForm> createState() =>
      _CharacterStatsSOEditorFormState();
}

class _CharacterStatsSOEditorFormState extends State<CharacterStatsSOEditorForm> {
  late CharacterStatsSOModel _model;

  @override
  void initState() {
    super.initState();
    _model = CharacterStatsSOModel.fromJson(widget.entry.payload);
  }

  double _dbl(String key, [double d = 0]) =>
      (_model.baseStats[key] ?? d).toDouble();

  void _set(String key, Object value) {
    final stats = Map<String, dynamic>.from(_model.baseStats);
    stats[key] = value;
    setState(() => _model = _model.copyWith(baseStats: stats));
    widget.onChanged(mergeEntryPayload(widget.entry, _model.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    final tempPref = Map<String, dynamic>.from(
      _model.baseStats['TemperaturePreference'] as Map? ??
          <String, dynamic>{'x': 20, 'y': 25},
    );
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        SectionCard(
          title: 'Base stats',
          child: Column(
            children: <Widget>[
              FloatField(
                label: 'Vitality',
                initialValue: _dbl('Vitality', 100),
                onChanged: (v) => _set('Vitality', v),
              ),
              FloatField(
                label: 'Energy regain rate',
                initialValue: _dbl('EnergyRegainRate'),
                onChanged: (v) => _set('EnergyRegainRate', v),
              ),
              FloatField(
                label: 'Satiety fall rate',
                initialValue: _dbl('SatietyFallRate'),
                onChanged: (v) => _set('SatietyFallRate', v),
              ),
              FloatField(
                label: 'Hydration fall rate',
                initialValue: _dbl('HydrationFallRate'),
                onChanged: (v) => _set('HydrationFallRate', v),
              ),
              Vector2Field(
                label: 'Temperature preference',
                value: tempPref,
                onChanged: (v) => _set('TemperaturePreference', v),
              ),
              FloatField(
                label: 'Temperature tolerance',
                initialValue: _dbl('TemperatureTolerance'),
                onChanged: (v) => _set('TemperatureTolerance', v),
              ),
              FloatField(
                label: 'Active illumination',
                initialValue: _dbl('ActiveIllumination'),
                onChanged: (v) => _set('ActiveIllumination', v),
              ),
              FloatField(
                label: 'Activity range',
                initialValue: _dbl('ActivityRange'),
                onChanged: (v) => _set('ActivityRange', v),
              ),
              FloatField(
                label: 'Dirtiness resistance',
                initialValue: _dbl('DirtinessResistance'),
                onChanged: (v) => _set('DirtinessResistance', v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:data_gen_ai/models/character_stats.dart';
import 'package:data_gen_ai/widgets/forms/float_field.dart';
import 'package:flutter/material.dart';

class CharacterStatsForm extends StatelessWidget {
  const CharacterStatsForm({
    super.key,
    required this.stats,
    required this.onChanged,
  });

  final CharacterStatsModel stats;
  final ValueChanged<CharacterStatsModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FloatField(
          label: 'Satiety',
          initialValue: stats.satiety,
          onChanged: (v) => onChanged(stats.copyWith(satiety: v)),
        ),
        FloatField(
          label: 'Hydration',
          initialValue: stats.hydration,
          onChanged: (v) => onChanged(stats.copyWith(hydration: v)),
        ),
        FloatField(
          label: 'Energy',
          initialValue: stats.energy,
          onChanged: (v) => onChanged(stats.copyWith(energy: v)),
        ),
        FloatField(
          label: 'Vitality',
          initialValue: stats.vitality,
          onChanged: (v) => onChanged(stats.copyWith(vitality: v)),
        ),
        FloatField(
          label: 'Max satiety',
          initialValue: stats.maxSatiety,
          onChanged: (v) => onChanged(stats.copyWith(maxSatiety: v)),
        ),
      ],
    );
  }
}

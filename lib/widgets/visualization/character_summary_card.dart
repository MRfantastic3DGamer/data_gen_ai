import 'package:data_gen_ai/models/character_data.dart';
import 'package:data_gen_ai/widgets/visualization/stat_bar.dart';
import 'package:flutter/material.dart';

class CharacterSummaryCard extends StatelessWidget {
  const CharacterSummaryCard({
    super.key,
    required this.data,
    required this.onTap,
  });

  final CharacterDataModel data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                data.description.isEmpty
                    ? 'Unnamed Character'
                    : data.description,
              ),
              const SizedBox(height: 8),
              StatBar(
                label: 'Vitality',
                value: data.initialStats.vitality,
                maxValue: 100,
              ),
              const SizedBox(height: 6),
              Text('Faction: ${data.faction}  Type: ${data.characterType}'),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class BeliefChainDiagram extends StatelessWidget {
  const BeliefChainDiagram({
    super.key,
    required this.beliefCount,
    required this.actionableCount,
  });

  final int beliefCount;
  final int actionableCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.hub_outlined),
            const SizedBox(width: 8),
            Text('Beliefs: $beliefCount  ->  Actionables: $actionableCount'),
          ],
        ),
      ),
    );
  }
}

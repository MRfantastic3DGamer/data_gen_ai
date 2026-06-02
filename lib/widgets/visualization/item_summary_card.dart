import 'package:data_gen_ai/models/item_data.dart';
import 'package:flutter/material.dart';

class ItemSummaryCard extends StatelessWidget {
  const ItemSummaryCard({super.key, required this.data, required this.onTap});

  final ItemDataModel data;
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
              Text(data.itemId.isEmpty ? 'Unnamed Item' : data.itemId),
              const SizedBox(height: 8),
              Text('Category: ${data.category}'),
              Text('Slots: ${data.interactionSlots.length}'),
            ],
          ),
        ),
      ),
    );
  }
}

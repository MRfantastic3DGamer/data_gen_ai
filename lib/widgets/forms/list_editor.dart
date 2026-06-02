import 'package:flutter/material.dart';

class ListEditor extends StatelessWidget {
  const ListEditor({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    required this.onAdd,
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
              ],
            ),
            const Divider(),
            if (itemCount == 0) const Text('No items'),
            for (int index = 0; index < itemCount; index++)
              itemBuilder(context, index),
          ],
        ),
      ),
    );
  }
}

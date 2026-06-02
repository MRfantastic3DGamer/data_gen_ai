import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GameData Editor')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _tile(
            context,
            'Characters',
            Icons.people_alt_outlined,
            '/characters',
          ),
          _tile(context, 'Items', Icons.inventory_2_outlined, '/items'),
          _tile(
            context,
            'All Scriptable Objects',
            Icons.folder_open_outlined,
            '/browser',
          ),
          _tile(context, 'AI Workspace', Icons.smart_toy_outlined, '/ai'),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}

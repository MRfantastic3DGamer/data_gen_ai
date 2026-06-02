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
            'Actions & Beliefs',
            'Search, filter, and edit exported JSON',
            Icons.play_circle_outline,
            '/actions',
          ),
          _tile(
            context,
            'Registries',
            'Factions & animation type tables (Unity dropdowns)',
            Icons.table_chart_outlined,
            '/registries',
          ),
          _tile(
            context,
            'JSON data folder',
            'Point at the RAW folder copied from Unity',
            Icons.folder_open_outlined,
            '/data-folder',
          ),
          _tile(
            context,
            'Characters',
            'Character JSON assets',
            Icons.people_alt_outlined,
            '/characters',
          ),
          _tile(
            context,
            'All JSON files',
            'Browse every exported file',
            Icons.description_outlined,
            '/browser',
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}

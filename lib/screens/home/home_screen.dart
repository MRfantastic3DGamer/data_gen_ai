import 'package:data_gen_ai/core/theme/app_spacing.dart';
import 'package:data_gen_ai/widgets/common/nav_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                topPadding + AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    colorScheme.primaryContainer,
                    colorScheme.surface,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.hub_outlined,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Character Design Editor',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Author character design graphs and export JSON for Unity',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.pagePadding(context),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                NavCard(
                  title: 'Character Design Graphs',
                  subtitle:
                      'Create nodes, wire typed ports, and save graph JSON for Unity import',
                  icon: Icons.account_tree_outlined,
                  iconColor: colorScheme.primary,
                  delayMs: 0,
                  onTap: () => context.push('/graphs'),
                ),
                NavCard(
                  title: 'Registries',
                  subtitle: 'Factions, actions, animation & work type tables',
                  icon: Icons.table_chart_rounded,
                  iconColor: colorScheme.secondary,
                  delayMs: 40,
                  onTap: () => context.push('/registries'),
                ),
                NavCard(
                  title: 'Settings',
                  subtitle: 'Data source, editor padding, and storage',
                  icon: Icons.settings_outlined,
                  iconColor: colorScheme.tertiary,
                  delayMs: 80,
                  onTap: () => context.push('/data-folder'),
                ),
                const SizedBox(height: AppSpacing.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

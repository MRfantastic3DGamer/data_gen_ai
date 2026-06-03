import 'package:data_gen_ai/core/constants.dart';
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
                              AppConstants.appName,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Edit Unity GameData via Firebase or local JSON',
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
                  title: 'Actions & Beliefs',
                  subtitle: 'Search, filter, and edit exported JSON',
                  icon: Icons.play_circle_outline_rounded,
                  iconColor: colorScheme.primary,
                  delayMs: 0,
                  onTap: () => context.push('/actions'),
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
                  title: 'Data source',
                  subtitle: 'Firebase Realtime DB or local RAW folder',
                  icon: Icons.cloud_sync_outlined,
                  iconColor: colorScheme.tertiary,
                  delayMs: 80,
                  onTap: () => context.push('/data-folder'),
                ),
                NavCard(
                  title: 'Characters',
                  subtitle: 'Character JSON assets',
                  icon: Icons.people_alt_rounded,
                  delayMs: 120,
                  onTap: () => context.push('/characters'),
                ),
                NavCard(
                  title: 'All JSON files',
                  subtitle: 'Browse every exported file',
                  icon: Icons.description_outlined,
                  delayMs: 160,
                  onTap: () => context.push('/browser'),
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

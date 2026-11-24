import 'package:flutter/material.dart';

import '../theme/ritma_spacing.dart';
import 'ritma_surface_badge.dart';

class RitmaNavDestination {
  const RitmaNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// Adaptive navigation scaffold supporting compact phone bottom bars (`< 600dp`),
/// tablet compact rails (`600-1023dp`), and desktop/web extended rails (`>= 1024dp`).
class RitmaResponsiveScaffold extends StatelessWidget {
  const RitmaResponsiveScaffold({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.body,
    super.key,
    this.appBarTitle,
    this.appBarActions,
    this.railHeader,
  });

  final List<RitmaNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final Widget body;
  final Widget? appBarTitle;
  final List<Widget>? appBarActions;
  final Widget? railHeader;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = width < 600;
        final isExpanded = width >= 1024;
        final safeIndex = selectedIndex.clamp(0, destinations.length - 1);

        if (isCompact) {
          return Scaffold(
            appBar: appBarTitle != null || appBarActions != null
                ? AppBar(title: appBarTitle, actions: appBarActions)
                : null,
            body: Column(
              children: [
                const RitmaSurfaceBadge(),
                Expanded(child: body),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: safeIndex,
              onDestinationSelected: onSelectIndex,
              destinations: destinations
                  .map(
                    (d) => NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    ),
                  )
                  .toList(),
            ),
          );
        }

        return Scaffold(
          appBar: appBarTitle != null || appBarActions != null
              ? AppBar(title: appBarTitle, actions: appBarActions)
              : null,
          body: Column(
            children: [
              const RitmaSurfaceBadge(),
              Expanded(
                child: Row(
                  children: [
                    NavigationRail(
                      extended: isExpanded,
                      selectedIndex: safeIndex,
                      onDestinationSelected: onSelectIndex,
                      leading: railHeader != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: RitmaSpacing.sm,
                                vertical: RitmaSpacing.sm,
                              ),
                              child: railHeader,
                            )
                          : null,
                      destinations: destinations
                          .map(
                            (d) => NavigationRailDestination(
                              icon: Icon(d.icon),
                              selectedIcon: Icon(d.selectedIcon),
                              label: Text(d.label),
                            ),
                          )
                          .toList(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

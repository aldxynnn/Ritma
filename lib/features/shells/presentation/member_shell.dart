import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/theme/ritma_theme.dart';
import '../../../core/widgets/ritma_responsive_scaffold.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';

class MemberShell extends ConsumerWidget {
  const MemberShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<RitmaNavDestination> _destinations = <RitmaNavDestination>[
    RitmaNavDestination(
      label: 'Pass',
      icon: Icons.qr_code_2_outlined,
      selectedIcon: Icons.qr_code_2,
    ),
    RitmaNavDestination(
      label: 'Schedule',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
    ),
    RitmaNavDestination(
      label: 'Bookings',
      icon: Icons.bookmark_border,
      selectedIcon: Icons.bookmark,
    ),
    RitmaNavDestination(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);

    return RitmaDensityScope(
      density: RitmaDensity.member,
      child: RitmaResponsiveScaffold(
        destinations: _destinations,
        selectedIndex: navigationShell.currentIndex,
        onSelectIndex: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        appBarTitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(workspace?.organizationName ?? 'RITMA'),
            if (workspace != null)
              Text(
                '${workspace.scopeLabel} • Member Pass',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        appBarActions: [
          IconButton(
            tooltip: 'Switch Workspace',
            onPressed: () => context.go(AppRoutes.workspaces),
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
        railHeader: workspace != null
            ? Padding(
                padding: const EdgeInsets.only(bottom: RitmaSpacing.sm),
                child: RitmaStatusPill(
                  label: workspace.scopeLabel,
                  icon: Icons.badge_outlined,
                  tone: RitmaPillTone.success,
                ),
              )
            : null,
        body: navigationShell,
      ),
    );
  }
}

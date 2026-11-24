import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/theme/ritma_theme.dart';
import '../../../core/widgets/ritma_responsive_scaffold.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/workspace_context.dart';

class _OpsTab {
  const _OpsTab({required this.branchIndex, required this.destination});

  final int branchIndex;
  final RitmaNavDestination destination;
}

class OpsShell extends ConsumerWidget {
  const OpsShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  List<_OpsTab> _visibleTabs(WorkspaceContext? workspace) {
    final tabs = <_OpsTab>[];

    final canDashboard =
        workspace != null &&
        (workspace.hasPermission('dashboard.org.read') ||
            workspace.hasPermission('dashboard.branch.read'));
    if (canDashboard) {
      tabs.add(
        const _OpsTab(
          branchIndex: 0,
          destination: RitmaNavDestination(
            label: 'Dashboard',
            icon: Icons.analytics_outlined,
            selectedIcon: Icons.analytics,
          ),
        ),
      );
    }

    final canCheckIn =
        workspace != null &&
        (workspace.hasPermission('checkin.perform') ||
            workspace.hasPermission('checkin.read'));
    if (canCheckIn) {
      tabs.add(
        const _OpsTab(
          branchIndex: 1,
          destination: RitmaNavDestination(
            label: 'Check-In',
            icon: Icons.qr_code_scanner_outlined,
            selectedIcon: Icons.qr_code_scanner,
          ),
        ),
      );
    }

    final canSchedule =
        workspace != null &&
        (workspace.hasPermission('schedule.manage') ||
            workspace.hasPermission('booking.read') ||
            workspace.hasPermission('attendance.mark') ||
            workspace.hasPermission('pt.manage'));
    if (canSchedule) {
      tabs.add(
        const _OpsTab(
          branchIndex: 2,
          destination: RitmaNavDestination(
            label: 'Schedule',
            icon: Icons.event_note_outlined,
            selectedIcon: Icons.event_note,
          ),
        ),
      );
    }

    final canMembers =
        workspace != null &&
        (workspace.hasPermission('member.read') ||
            workspace.hasPermission('entitlement.read') ||
            workspace.hasPermission('package.manage'));
    if (canMembers) {
      tabs.add(
        const _OpsTab(
          branchIndex: 3,
          destination: RitmaNavDestination(
            label: 'Members',
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
          ),
        ),
      );
    }

    tabs.add(
      const _OpsTab(
        branchIndex: 4,
        destination: RitmaNavDestination(
          label: 'Settings',
          icon: Icons.tune_outlined,
          selectedIcon: Icons.tune,
        ),
      ),
    );

    return tabs;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final visibleTabs = _visibleTabs(workspace);
    final currentPos = visibleTabs.indexWhere(
      (t) => t.branchIndex == navigationShell.currentIndex,
    );
    final selectedPos = currentPos >= 0 ? currentPos : 0;

    return RitmaDensityScope(
      density: RitmaDensity.operations,
      child: RitmaResponsiveScaffold(
        destinations: visibleTabs.map((t) => t.destination).toList(),
        selectedIndex: selectedPos,
        onSelectIndex: (index) {
          final targetBranch = visibleTabs[index].branchIndex;
          navigationShell.goBranch(
            targetBranch,
            initialLocation: targetBranch == navigationShell.currentIndex,
          );
        },
        appBarTitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(workspace?.organizationName ?? 'RITMA Operations'),
            if (workspace != null)
              Text(
                '${workspace.roleDisplayName} • ${workspace.scopeLabel}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        appBarActions: [
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.workspaces),
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('Switch'),
          ),
        ],
        railHeader: workspace != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RitmaStatusPill(
                    label: workspace.roleDisplayName,
                    icon: Icons.admin_panel_settings_outlined,
                    tone: RitmaPillTone.lime,
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                  RitmaStatusPill(
                    label: workspace.scopeLabel,
                    icon: Icons.location_on_outlined,
                  ),
                ],
              )
            : null,
        body: navigationShell,
      ),
    );
  }
}

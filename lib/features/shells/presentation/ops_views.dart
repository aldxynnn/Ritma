import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/ritma_metric_tile.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../members/presentation/members_directory_view.dart';
import '../../packages/presentation/packages_catalog_view.dart';

class OpsDashboardView extends ConsumerWidget {
  const OpsDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RitmaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(RitmaSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: RitmaSpacing.xs,
                    runSpacing: RitmaSpacing.xs,
                    children: [
                      const RitmaStatusPill(
                        label: 'Operations Console',
                        icon: Icons.analytics_outlined,
                        tone: RitmaPillTone.lime,
                      ),
                      if (workspace != null)
                        RitmaStatusPill(label: workspace.scopeLabel),
                    ],
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                  Text(
                    workspace?.organizationName ?? 'Operations Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: RitmaSpacing.xxs),
                  Text(
                    'All KPIs query get_operational_dashboard_metrics() directly from PostgreSQL once connected. Zero placeholder numbers are fabricated.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: RitmaSpacing.md),
          const Wrap(
            spacing: RitmaSpacing.sm,
            runSpacing: RitmaSpacing.sm,
            children: [
              SizedBox(
                width: 220,
                child: RitmaMetricTile(
                  label: 'Active Members',
                  value: '—',
                  caption: 'Awaiting live org data',
                  icon: Icons.people_outline,
                ),
              ),
              SizedBox(
                width: 220,
                child: RitmaMetricTile(
                  label: "Today's Gym Visits",
                  value: '—',
                  caption: 'Awaiting live check-ins',
                  icon: Icons.qr_code_scanner,
                ),
              ),
              SizedBox(
                width: 220,
                child: RitmaMetricTile(
                  label: 'Class Occupancy',
                  value: '—',
                  caption: 'Awaiting scheduled sessions',
                  icon: Icons.event_available_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OpsCheckInView extends StatelessWidget {
  const OpsCheckInView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OpsModulePlaceholder(
      title: 'Front-Desk Facility Check-In',
      subtitle: 'Rotating QR validation, cooldown protection, and visit logs',
      icon: Icons.qr_code_scanner,
      description: 'Backed by validate_and_check_in and manual_facility_check_in RPCs enforcing facility_access entitlements per branch.',
    );
  }
}

class OpsScheduleView extends StatelessWidget {
  const OpsScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OpsModulePlaceholder(
      title: 'Schedules & Live Roster',
      subtitle: 'Class sessions, waitlist queues, and attendance marking',
      icon: Icons.event_note_outlined,
      description: 'Backed by class_sessions, get_session_roster, and mark_class_attendance RPCs respecting branch and instructor isolation.',
    );
  }
}

class OpsMembersView extends ConsumerStatefulWidget {
  const OpsMembersView({super.key});

  @override
  ConsumerState<OpsMembersView> createState() => _OpsMembersViewState();
}

class _OpsMembersViewState extends ConsumerState<OpsMembersView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final canMembers =
        ref.watch(hasPermissionProvider('member.read')) ||
        ref.watch(hasPermissionProvider('entitlement.read'));
    final canPackages =
        ref.watch(hasPermissionProvider('package.manage')) ||
        ref.watch(hasPermissionProvider('entitlement.assign'));

    if (!canMembers && canPackages) {
      return const PackagesCatalogView();
    }
    if (canMembers && !canPackages) {
      return const MembersDirectoryView();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            RitmaSpacing.md,
            RitmaSpacing.md,
            RitmaSpacing.md,
            0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(
                  value: 0,
                  icon: Icon(Icons.people_outline),
                  label: Text('Members'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: Icon(Icons.inventory_2_outlined),
                  label: Text('Packages'),
                ),
              ],
              selected: <int>{_tab},
              onSelectionChanged: (values) =>
                  setState(() => _tab = values.first),
            ),
          ),
        ),
        Expanded(
          child: _tab == 0
              ? const MembersDirectoryView()
              : const PackagesCatalogView(),
        ),
      ],
    );
  }
}

class _OpsModulePlaceholder extends StatelessWidget {
  const _OpsModulePlaceholder({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(RitmaSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(RitmaSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RitmaSectionHeader(
                title: title,
                subtitle: subtitle,
                trailing: Icon(icon),
              ),
              const SizedBox(height: RitmaSpacing.sm),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

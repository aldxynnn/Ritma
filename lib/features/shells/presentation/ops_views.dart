import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../auth/application/auth_providers.dart';
import '../../booking/presentation/ops_schedule_roster_view.dart';
import '../../dashboard/presentation/ops_dashboard_view.dart';
import '../../facility_access/presentation/front_desk_checkin_view.dart';
import '../../members/presentation/members_directory_view.dart';
import '../../packages/presentation/packages_catalog_view.dart';

class OpsDashboardView extends StatelessWidget {
  const OpsDashboardView({super.key});

  @override
  Widget build(BuildContext context) => const LiveOpsDashboardView();
}

class OpsCheckInView extends StatelessWidget {
  const OpsCheckInView({super.key});

  @override
  Widget build(BuildContext context) => const FrontDeskCheckInView();
}

class OpsScheduleView extends StatelessWidget {
  const OpsScheduleView({super.key});

  @override
  Widget build(BuildContext context) => const OpsScheduleRosterView();
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

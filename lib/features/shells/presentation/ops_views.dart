import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../auth/application/auth_providers.dart';
import '../../booking/presentation/ops_schedule_roster_view.dart';
import '../../dashboard/presentation/ops_dashboard_view.dart';
import '../../facility_access/presentation/front_desk_checkin_view.dart';
import '../../members/presentation/members_directory_view.dart';
import '../../packages/presentation/packages_catalog_view.dart';
import '../../payments/presentation/payments_ledger_view.dart';
import '../../personal_training/presentation/pt_sessions_view.dart';

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

class OpsScheduleView extends ConsumerStatefulWidget {
  const OpsScheduleView({super.key});

  @override
  ConsumerState<OpsScheduleView> createState() => _OpsScheduleViewState();
}

class _OpsScheduleViewState extends ConsumerState<OpsScheduleView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final canClasses =
        ref.watch(hasPermissionProvider('schedule.manage')) ||
        ref.watch(hasPermissionProvider('booking.read')) ||
        ref.watch(hasPermissionProvider('attendance.mark')) ||
        ref.watch(hasPermissionProvider('booking.manage'));
    final canPt = ref.watch(hasPermissionProvider('pt.manage'));

    if (!canClasses && canPt) {
      return const PtSessionsView();
    }
    if (!canPt || !canClasses) {
      return const OpsScheduleRosterView();
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
                  icon: Icon(Icons.event_note_outlined),
                  label: Text('Classes'),
                ),
                ButtonSegment<int>(
                  value: 1,
                  icon: Icon(Icons.fitness_center_outlined),
                  label: Text('Personal Training'),
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
              ? const OpsScheduleRosterView()
              : const PtSessionsView(),
        ),
      ],
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
    final canPayments = ref.watch(hasPermissionProvider('payment.read'));

    final segments = <ButtonSegment<int>>[
      if (canMembers)
        const ButtonSegment<int>(
          value: 0,
          icon: Icon(Icons.people_outline),
          label: Text('Members'),
        ),
      if (canPackages)
        const ButtonSegment<int>(
          value: 1,
          icon: Icon(Icons.inventory_2_outlined),
          label: Text('Packages'),
        ),
      if (canPayments)
        const ButtonSegment<int>(
          value: 2,
          icon: Icon(Icons.receipt_long_outlined),
          label: Text('Payments'),
        ),
    ];

    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }
    if (segments.length == 1) {
      return _tabBody(segments.first.value);
    }
    final activeTab = segments.any((s) => s.value == _tab)
        ? _tab
        : segments.first.value;

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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<int>(
                segments: segments,
                selected: <int>{activeTab},
                onSelectionChanged: (values) =>
                    setState(() => _tab = values.first),
              ),
            ),
          ),
        ),
        Expanded(child: _tabBody(activeTab)),
      ],
    );
  }

  Widget _tabBody(int value) {
    return switch (value) {
      0 => const MembersDirectoryView(),
      1 => const PackagesCatalogView(),
      _ => const PaymentsLedgerView(),
    };
  }
}

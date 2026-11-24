import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_metric_tile.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../facility_access/application/facility_access_providers.dart';
import '../../facility_access/domain/facility_access_models.dart';
import '../application/dashboard_providers.dart';
import '../domain/operational_metrics_model.dart';

class LiveOpsDashboardView extends ConsumerWidget {
  const LiveOpsDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final windowDays = ref.watch(dashboardWindowDaysProvider);
    final metricsAsync = ref.watch(operationalMetricsProvider);
    final visitsAsync = ref.watch(branchVisitsProvider);

    final numFmt = NumberFormat.decimalPattern();
    final moneyFmt = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(operationalMetricsProvider);
        ref.invalidate(branchVisitsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            workspace?.organizationName ??
                                'Operations Dashboard',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh KPIs',
                          onPressed: () {
                            ref.invalidate(operationalMetricsProvider);
                            ref.invalidate(branchVisitsProvider);
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: RitmaSpacing.sm),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(value: 7, label: Text('7 Days')),
                        ButtonSegment<int>(value: 30, label: Text('30 Days')),
                      ],
                      selected: <int>{windowDays},
                      onSelectionChanged: (selection) {
                        if (selection.isNotEmpty) {
                          ref
                              .read(dashboardWindowDaysProvider.notifier)
                              .setWindow(selection.first);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: RitmaSpacing.md),
            AsyncStateView<OperationalMetricsModel>(
              value: metricsAsync,
              onRetry: () => ref.invalidate(operationalMetricsProvider),
              data: (metrics) => Wrap(
                spacing: RitmaSpacing.sm,
                runSpacing: RitmaSpacing.sm,
                children: [
                  SizedBox(
                    width: 220,
                    child: RitmaMetricTile(
                      label: 'Active Members',
                      value: numFmt.format(metrics.activeMembers),
                      caption: 'Scoped roster',
                      icon: Icons.people_outline,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: RitmaMetricTile(
                      label: "Today's Gym Visits",
                      value: numFmt.format(metrics.todayVisits),
                      caption: 'Validated facility entries',
                      icon: Icons.qr_code_scanner,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: RitmaMetricTile(
                      label: 'Class Occupancy',
                      value: '${metrics.classOccupancyPct.toStringAsFixed(1)}%',
                      caption:
                          '${metrics.classConfirmedTotal}/${metrics.classCapacityTotal} seats booked',
                      icon: Icons.event_available_outlined,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: RitmaMetricTile(
                      label: 'Revenue (${windowDays}d)',
                      value: moneyFmt.format(
                        metrics.windowRevenueMinor / 100.0,
                      ),
                      caption: 'Succeeded package payments',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: RitmaMetricTile(
                      label: 'Expiring in 7d',
                      value: numFmt.format(metrics.expiringEntitlements7d),
                      caption: 'Passes nearing expiry',
                      icon: Icons.schedule_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: RitmaSpacing.lg),
            const RitmaSectionHeader(
              title: 'Recent Check-Ins',
              subtitle: 'Latest facility entries in the active scope',
            ),
            const SizedBox(height: RitmaSpacing.sm),
            AsyncStateView<List<FacilityVisitModel>>(
              value: visitsAsync,
              isEmpty: (visits) => visits.isEmpty,
              emptyTitle: 'No check-ins recorded yet',
              emptyMessage:
                  'Entries logged via QR or manual desk reception appear here.',
              onRetry: () => ref.invalidate(branchVisitsProvider),
              data: (visits) {
                final fmt = DateFormat.MMMd().add_jm();
                return Column(
                  children: visits
                      .take(5)
                      .map(
                        (v) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: RitmaSpacing.xs,
                          ),
                          child: Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.door_front_door_outlined,
                              ),
                              title: Text(
                                v.memberName ??
                                    'Member ${v.memberId.substring(0, 8)}',
                              ),
                              subtitle: Text(
                                fmt.format(v.checkedInAt.toLocal()),
                              ),
                              trailing: RitmaStatusPill(
                                label: v.checkInMethod.toUpperCase(),
                                tone: v.checkedOutAt == null
                                    ? RitmaPillTone.success
                                    : RitmaPillTone.neutral,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

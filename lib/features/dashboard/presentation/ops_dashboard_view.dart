import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_metric_tile.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../booking/application/booking_providers.dart';
import '../../booking/domain/booking_models.dart';
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
    final sessionsAsync = ref.watch(classSessionsProvider);

    final numFmt = NumberFormat.decimalPattern();
    final moneyFmt = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(operationalMetricsProvider);
        ref.invalidate(branchVisitsProvider);
        ref.invalidate(classSessionsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: RitmaPageContainer(
          maxWidth: 1200,
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
                            RitmaStatusPill(
                              label: workspace.scopeLabel,
                              icon: Icons.location_on_outlined,
                            ),
                          if (workspace != null)
                            RitmaStatusPill(
                              label: workspace.roleDisplayName,
                              icon: Icons.badge_outlined,
                            ),
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
                              ref.invalidate(classSessionsProvider);
                            },
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: RitmaSpacing.sm),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: RitmaSpacing.sm,
                        runSpacing: RitmaSpacing.sm,
                        children: [
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment<int>(
                                value: 7,
                                label: Text('7 Days'),
                              ),
                              ButtonSegment<int>(
                                value: 30,
                                label: Text('30 Days'),
                              ),
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
                          if (workspace != null)
                            Wrap(
                              spacing: RitmaSpacing.xs,
                              runSpacing: RitmaSpacing.xs,
                              children: [
                                if (workspace.hasPermission('checkin.perform'))
                                  FilledButton.tonalIcon(
                                    onPressed: () =>
                                        context.go(AppRoutes.opsCheckIn),
                                    icon: const Icon(
                                      Icons.qr_code_scanner,
                                      size: 18,
                                    ),
                                    label: const Text('Desk Check-In'),
                                  ),
                                if (workspace.hasPermission(
                                      'schedule.manage',
                                    ) ||
                                    workspace.hasPermission('booking.read'))
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        context.go(AppRoutes.opsSchedule),
                                    icon: const Icon(
                                      Icons.event_note_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Class Schedule'),
                                  ),
                                if (workspace.hasPermission('member.read'))
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        context.go(AppRoutes.opsMembers),
                                    icon: const Icon(
                                      Icons.people_outline,
                                      size: 18,
                                    ),
                                    label: const Text('Member Directory'),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: RitmaSpacing.md),
              AsyncStateView<OperationalMetricsModel>(
                value: metricsAsync,
                onRetry: () => ref.invalidate(operationalMetricsProvider),
                data: (metrics) {
                  final tiles = <Widget>[
                    RitmaMetricTile(
                      label: 'Active Members',
                      value: numFmt.format(metrics.activeMembers),
                      caption: 'Scoped roster',
                      icon: Icons.people_outline,
                    ),
                    RitmaMetricTile(
                      label: "Today's Gym Visits",
                      value: numFmt.format(metrics.todayVisits),
                      caption: 'Validated entries',
                      icon: Icons.qr_code_scanner,
                      highlighted: true,
                    ),
                    RitmaMetricTile(
                      label: 'Class Occupancy',
                      value: '${metrics.classOccupancyPct.toStringAsFixed(1)}%',
                      caption:
                          '${metrics.classConfirmedTotal}/${metrics.classCapacityTotal} seats',
                      icon: Icons.event_available_outlined,
                    ),
                    RitmaMetricTile(
                      label: 'Revenue (${windowDays}d)',
                      value: moneyFmt.format(
                        metrics.windowRevenueMinor / 100.0,
                      ),
                      caption: 'Paid subscriptions',
                      icon: Icons.payments_outlined,
                      highlighted: metrics.windowRevenueMinor > 0,
                    ),
                    RitmaMetricTile(
                      label: 'Expiring in 7d',
                      value: numFmt.format(metrics.expiringEntitlements7d),
                      caption: 'Renewals due',
                      icon: Icons.schedule_outlined,
                    ),
                  ];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final scaleLarge =
                          MediaQuery.textScalerOf(context).scale(14) > 16;
                      final cols = scaleLarge
                          ? (constraints.maxWidth >= 820 ? 3 : 2)
                          : constraints.maxWidth >= 1020
                          ? 5
                          : constraints.maxWidth >= 660
                          ? 3
                          : 2;
                      const gap = RitmaSpacing.sm;
                      final tileWidth =
                          (constraints.maxWidth - (cols - 1) * gap) / cols;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: tiles
                            .map(
                              (tile) => SizedBox(width: tileWidth, child: tile),
                            )
                            .toList(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: RitmaSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final twoColumn = constraints.maxWidth >= 880;
                  final checkInsSection = _RecentCheckInsPanel(
                    visitsAsync: visitsAsync,
                    onRetry: () => ref.invalidate(branchVisitsProvider),
                    onOpenCheckIn:
                        workspace?.hasPermission('checkin.perform') == true
                        ? () => context.go(AppRoutes.opsCheckIn)
                        : null,
                  );
                  final upcomingClassesSection = _UpcomingClassesPanel(
                    sessionsAsync: sessionsAsync,
                    onRetry: () => ref.invalidate(classSessionsProvider),
                    onOpenSchedule: () => context.go(AppRoutes.opsSchedule),
                  );

                  if (twoColumn) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: checkInsSection),
                        const SizedBox(width: RitmaSpacing.md),
                        Expanded(child: upcomingClassesSection),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      checkInsSection,
                      const SizedBox(height: RitmaSpacing.lg),
                      upcomingClassesSection,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentCheckInsPanel extends StatelessWidget {
  const _RecentCheckInsPanel({
    required this.visitsAsync,
    required this.onRetry,
    this.onOpenCheckIn,
  });

  final AsyncValue<List<FacilityVisitModel>> visitsAsync;
  final VoidCallback onRetry;
  final VoidCallback? onOpenCheckIn;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.MMMd().add_jm();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RitmaSectionHeader(
          title: 'Recent Check-Ins',
          subtitle: 'Latest facility entries in the active scope',
          trailing: onOpenCheckIn != null
              ? TextButton(
                  onPressed: onOpenCheckIn,
                  child: const Text('Desk Console'),
                )
              : null,
        ),
        const SizedBox(height: RitmaSpacing.sm),
        AsyncStateView<List<FacilityVisitModel>>(
          value: visitsAsync,
          isEmpty: (visits) => visits.isEmpty,
          emptyTitle: 'No check-ins recorded yet',
          emptyMessage:
              'Entries logged via QR or manual desk reception appear here.',
          onRetry: onRetry,
          data: (visits) => Column(
            children: visits
                .take(5)
                .map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(bottom: RitmaSpacing.xs),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: v.checkedOutAt == null
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                          child: Icon(
                            v.checkInMethod == 'qr'
                                ? Icons.qr_code_scanner
                                : Icons.badge_outlined,
                            size: 18,
                            color: v.checkedOutAt == null
                                ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                : Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                          ),
                        ),
                        title: Text(
                          (v.memberName != null &&
                                  v.memberName!.trim().isNotEmpty)
                              ? v.memberName!
                              : 'Member ${v.memberId.substring(0, 8)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${fmt.format(v.checkedInAt.toLocal())} • ${v.checkInMethod.toUpperCase()}',
                        ),
                        trailing: RitmaStatusPill(
                          label: v.checkedOutAt == null ? 'ON FLOOR' : 'OUT',
                          tone: v.checkedOutAt == null
                              ? RitmaPillTone.success
                              : RitmaPillTone.neutral,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _UpcomingClassesPanel extends StatelessWidget {
  const _UpcomingClassesPanel({
    required this.sessionsAsync,
    required this.onRetry,
    required this.onOpenSchedule,
  });

  final AsyncValue<List<ClassSessionModel>> sessionsAsync;
  final VoidCallback onRetry;
  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.MMMEd().add_jm();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RitmaSectionHeader(
          title: 'Upcoming Classes',
          subtitle: 'Live roster utilization & capacity',
          trailing: TextButton(
            onPressed: onOpenSchedule,
            child: const Text('All Sessions'),
          ),
        ),
        const SizedBox(height: RitmaSpacing.sm),
        AsyncStateView<List<ClassSessionModel>>(
          value: sessionsAsync,
          isEmpty: (list) => list.isEmpty,
          emptyTitle: 'No upcoming classes',
          emptyMessage: 'Publish a studio session to start accepting bookings.',
          onRetry: onRetry,
          data: (sessions) {
            final active = sessions
                .where((s) => s.status != SessionStatus.cancelled)
                .take(5)
                .toList();
            if (active.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(RitmaSpacing.md),
                  child: Text(
                    'All upcoming sessions are currently cancelled.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              );
            }
            return Column(
              children: active.map((session) {
                final ratio = session.capacity > 0
                    ? (session.confirmedCount / session.capacity)
                          .clamp(0.0, 1.0)
                          .toDouble()
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: RitmaSpacing.xs),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(RitmaSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  session.title,
                                  style: Theme.of(context).textTheme.titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: RitmaSpacing.xs),
                              RitmaStatusPill(
                                label: session.isFull
                                    ? 'FULL (${session.confirmedCount}/${session.capacity})'
                                    : '${session.confirmedCount}/${session.capacity}',
                                tone: session.isFull
                                    ? RitmaPillTone.warning
                                    : RitmaPillTone.success,
                              ),
                            ],
                          ),
                          const SizedBox(height: RitmaSpacing.xxs),
                          Text(
                            '${fmt.format(session.startsAt.toLocal())}'
                            '${session.instructorDisplayName.isNotEmpty ? ' • ${session.instructorDisplayName}' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: RitmaSpacing.xs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(RitmaRadius.sm),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 6,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

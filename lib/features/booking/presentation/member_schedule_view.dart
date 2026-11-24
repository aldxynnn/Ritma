import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../../packages/application/package_providers.dart';
import '../application/booking_providers.dart';
import '../domain/booking_models.dart';

class MemberScheduleBrowseView extends ConsumerStatefulWidget {
  const MemberScheduleBrowseView({super.key});

  @override
  ConsumerState<MemberScheduleBrowseView> createState() =>
      _MemberScheduleBrowseViewState();
}

class _MemberScheduleBrowseViewState
    extends ConsumerState<MemberScheduleBrowseView> {
  String? _bookingSessionId;

  Future<void> _bookSession({
    required String orgId,
    required String memberId,
    required ClassSessionModel session,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    if (repo == null) {
      return;
    }
    setState(() => _bookingSessionId = session.id);
    final res = await repo.bookClassSession(
      orgId: orgId,
      sessionId: session.id,
      memberId: memberId,
      idempotencyKey: const Uuid().v4(),
    );
    if (!mounted) {
      return;
    }
    setState(() => _bookingSessionId = null);
    res.when(
      success: (outcome) {
        ref.invalidate(classSessionsProvider);
        ref.invalidate(memberBookingsProvider);
        ref.invalidate(memberWalletProvider(memberId));
        final message = outcome.status == BookingStatus.waitlisted
            ? 'Added to waitlist (#${outcome.waitlistPosition ?? '-'}).'
            : 'Booking confirmed for ${session.title}.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      },
      failure: (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final memberId = workspace?.memberId;
    if (workspace == null) {
      return const SizedBox.shrink();
    }

    final sessionsAsync = ref.watch(classSessionsProvider);
    final bookings =
        ref.watch(memberBookingsProvider).asData?.value ??
        const <ClassBookingModel>[];
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final branchMap = <String, String>{for (final b in branches) b.id: b.name};

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(classSessionsProvider);
        ref.invalidate(memberBookingsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: RitmaPageContainer(
          maxWidth: 960,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RitmaSectionHeader(
                title: 'Class Schedule',
                subtitle: 'Reserve studio classes and track live capacity',
                trailing: IconButton(
                  tooltip: 'Refresh schedule',
                  onPressed: () => ref.invalidate(classSessionsProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ),
              const SizedBox(height: RitmaSpacing.md),
              AsyncStateView<List<ClassSessionModel>>(
                value: sessionsAsync,
                isEmpty: (list) => list.isEmpty,
                emptyTitle: 'No upcoming classes scheduled',
                emptyMessage:
                    'Check back once instructors publish new classes.',
                onRetry: () => ref.invalidate(classSessionsProvider),
                data: (sessions) {
                  final dayFmt = DateFormat.MMMEd();
                  final timeFmt = DateFormat.jm();
                  final active = sessions
                      .where((s) => s.status != SessionStatus.cancelled)
                      .toList();
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth >= 780 ? 2 : 1;
                      const gap = RitmaSpacing.sm;
                      final cardWidth =
                          (constraints.maxWidth - (cols - 1) * gap) / cols;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: active.map((session) {
                          final activeBooking = bookings.where((b) {
                            return b.sessionId == session.id &&
                                (b.status == BookingStatus.confirmed ||
                                    b.status == BookingStatus.waitlisted);
                          }).firstOrNull;
                          final busy = _bookingSessionId == session.id;
                          final branchName =
                              branchMap[session.branchId] ?? 'Branch';
                          final ratio = session.capacity > 0
                              ? (session.confirmedCount / session.capacity)
                                    .clamp(0.0, 1.0)
                                    .toDouble()
                              : 0.0;

                          return SizedBox(
                            width: cardWidth,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(RitmaSpacing.md),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Wrap(
                                      spacing: RitmaSpacing.xs,
                                      runSpacing: RitmaSpacing.xs,
                                      children: [
                                        RitmaStatusPill(
                                          label: branchName,
                                          icon: Icons.place_outlined,
                                        ),
                                        RitmaStatusPill(
                                          label: session.isFull
                                              ? 'Full (Waitlist)'
                                              : '${session.remainingSpots} spots left',
                                          tone: session.isFull
                                              ? RitmaPillTone.warning
                                              : RitmaPillTone.success,
                                        ),
                                        RitmaStatusPill(
                                          label: '${session.creditCost} credit',
                                          tone: RitmaPillTone.lime,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: RitmaSpacing.sm),
                                    Text(
                                      session.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: RitmaSpacing.xxs),
                                    Text(
                                      '${dayFmt.format(session.startsAt.toLocal())} • ${timeFmt.format(session.startsAt.toLocal())} – ${timeFmt.format(session.endsAt.toLocal())}'
                                      '${session.instructorDisplayName.isNotEmpty ? ' • ${session.instructorDisplayName}' : ''}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    const SizedBox(height: RitmaSpacing.xs),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        RitmaRadius.sm,
                                      ),
                                      child: LinearProgressIndicator(
                                        value: ratio,
                                        minHeight: 5,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                    const SizedBox(height: RitmaSpacing.sm),
                                    if (activeBooking != null)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: RitmaStatusPill(
                                          label:
                                              activeBooking.status ==
                                                  BookingStatus.waitlisted
                                              ? 'Waitlisted #${activeBooking.waitlistPosition ?? '-'}'
                                              : 'Booked',
                                          icon: Icons.event_available,
                                          tone:
                                              activeBooking.status ==
                                                  BookingStatus.waitlisted
                                              ? RitmaPillTone.warning
                                              : RitmaPillTone.success,
                                        ),
                                      )
                                    else if (memberId != null)
                                      FilledButton.icon(
                                        onPressed: busy
                                            ? null
                                            : () => _bookSession(
                                                orgId: workspace.organizationId,
                                                memberId: memberId,
                                                session: session,
                                              ),
                                        icon: Icon(
                                          session.isFull
                                              ? Icons.hourglass_top
                                              : Icons.add_task,
                                          size: 18,
                                        ),
                                        label: Text(
                                          busy
                                              ? 'Reserving...'
                                              : session.isFull
                                              ? 'Join Waitlist'
                                              : 'Book Class',
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

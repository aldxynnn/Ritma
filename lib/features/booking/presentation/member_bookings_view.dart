import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../packages/application/package_providers.dart';
import '../application/booking_providers.dart';
import '../domain/booking_models.dart';

class MemberBookingsListView extends ConsumerStatefulWidget {
  const MemberBookingsListView({super.key});

  @override
  ConsumerState<MemberBookingsListView> createState() =>
      _MemberBookingsListViewState();
}

class _MemberBookingsListViewState
    extends ConsumerState<MemberBookingsListView> {
  String? _cancellingId;

  Future<void> _confirmAndCancel({
    required String orgId,
    required String memberId,
    required ClassBookingModel booking,
    ClassSessionModel? session,
  }) async {
    final now = DateTime.now().toUtc();
    final eligibleRefund =
        booking.status == BookingStatus.confirmed &&
        session != null &&
        now.isBefore(session.cancellationCutoffAt);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Class Booking?'),
        content: Text(
          eligibleRefund
              ? 'This cancellation is before the cutoff window. ${booking.creditCost} class credit(s) will be refunded automatically.'
              : booking.status == BookingStatus.waitlisted
              ? 'You will be removed from the waitlist queue.'
              : 'This cancellation is past the cutoff window and is non-refundable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Booking'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    final repo = ref.read(bookingRepositoryProvider);
    if (repo == null) {
      return;
    }
    setState(() => _cancellingId = booking.id);
    final res = await repo.cancelClassBooking(
      orgId: orgId,
      bookingId: booking.id,
    );
    if (!mounted) {
      return;
    }
    setState(() => _cancellingId = null);
    res.when(
      success: (outcome) {
        ref.invalidate(memberBookingsProvider);
        ref.invalidate(classSessionsProvider);
        ref.invalidate(memberWalletProvider(memberId));
        final msg = outcome.refundedCredits > 0
            ? 'Cancelled. Refunded ${outcome.refundedCredits} credit(s).'
            : 'Booking cancelled.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
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

    final bookingsAsync = ref.watch(memberBookingsProvider);
    final sessions =
        ref.watch(classSessionsProvider).asData?.value ??
        const <ClassSessionModel>[];
    final sessionMap = <String, ClassSessionModel>{
      for (final s in sessions) s.id: s,
    };

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(memberBookingsProvider);
        ref.invalidate(classSessionsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(RitmaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RitmaSectionHeader(
              title: 'My Bookings',
              subtitle: 'Confirmed classes, waitlist position, and attendance history',
              trailing: IconButton(
                tooltip: 'Refresh bookings',
                onPressed: () => ref.invalidate(memberBookingsProvider),
                icon: const Icon(Icons.refresh),
              ),
            ),
            const SizedBox(height: RitmaSpacing.md),
            AsyncStateView<List<ClassBookingModel>>(
              value: bookingsAsync,
              isEmpty: (list) => list.isEmpty,
              emptyTitle: 'No class bookings yet',
              emptyMessage: 'Explore the Schedule tab to book a studio or functional class.',
              onRetry: () => ref.invalidate(memberBookingsProvider),
              data: (bookings) {
                final timeFmt = DateFormat.MMMEd().add_jm();
                return Column(
                  children: bookings.map((booking) {
                    final session = sessionMap[booking.sessionId];
                    final canCancel =
                        booking.status == BookingStatus.confirmed ||
                        booking.status == BookingStatus.waitlisted;
                    final tone = switch (booking.status) {
                      BookingStatus.confirmed => RitmaPillTone.success,
                      BookingStatus.waitlisted => RitmaPillTone.warning,
                      BookingStatus.cancelledEarly => RitmaPillTone.neutral,
                      BookingStatus.cancelledLate => RitmaPillTone.danger,
                      BookingStatus.expiredUnpromoted => RitmaPillTone.neutral,
                    };

                    return Padding(
                      padding: const EdgeInsets.only(bottom: RitmaSpacing.sm),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(RitmaSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: RitmaSpacing.xs,
                                runSpacing: RitmaSpacing.xs,
                                children: [
                                  RitmaStatusPill(
                                    label:
                                        booking.status ==
                                            BookingStatus.waitlisted
                                        ? 'Waitlisted #${booking.waitlistPosition ?? '-'}'
                                        : booking.status.displayLabel,
                                    tone: tone,
                                  ),
                                  RitmaStatusPill(
                                    label:
                                        booking.attendanceStatus.displayLabel,
                                    tone:
                                        booking.attendanceStatus ==
                                            AttendanceStatus.checkedIn
                                        ? RitmaPillTone.lime
                                        : RitmaPillTone.neutral,
                                  ),
                                ],
                              ),
                              const SizedBox(height: RitmaSpacing.xs),
                              Text(
                                session?.title ??
                                    'Session ${booking.sessionId.substring(0, 8)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: RitmaSpacing.xxs),
                              Text(
                                session != null
                                    ? timeFmt.format(session.startsAt.toLocal())
                                    : 'Booked ${timeFmt.format(booking.bookedAt.toLocal())}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (canCancel && memberId != null) ...[
                                const SizedBox(height: RitmaSpacing.sm),
                                OutlinedButton.icon(
                                  onPressed: _cancellingId == booking.id
                                      ? null
                                      : () => _confirmAndCancel(
                                          orgId: workspace.organizationId,
                                          memberId: memberId,
                                          booking: booking,
                                          session: session,
                                        ),
                                  icon: const Icon(Icons.close, size: 18),
                                  label: Text(
                                    _cancellingId == booking.id
                                        ? 'Cancelling...'
                                        : 'Cancel Booking',
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}

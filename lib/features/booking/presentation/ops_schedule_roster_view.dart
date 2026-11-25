import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/state/ritma_sync.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/theme/ritma_status_colors.dart';
import '../../../core/utils/ritma_timezone.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_session_state.dart';
import '../../members/application/member_providers.dart';
import '../../members/domain/member_model.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../../organizations/domain/room_model.dart';
import '../../packages/application/package_providers.dart';
import '../../packages/domain/package_models.dart';
import '../application/booking_providers.dart';
import '../domain/booking_models.dart';

class OpsScheduleRosterView extends ConsumerStatefulWidget {
  const OpsScheduleRosterView({super.key});

  @override
  ConsumerState<OpsScheduleRosterView> createState() =>
      _OpsScheduleRosterViewState();
}

class _OpsScheduleRosterViewState extends ConsumerState<OpsScheduleRosterView> {
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(activeWorkspaceProvider);
    if (workspace == null) {
      return const SizedBox.shrink();
    }

    final authState = ref.watch(authControllerProvider).asData?.value;
    final currentUserId = switch (authState) {
      AuthenticatedSession(:final user) => user.id,
      _ => null,
    };

    final sessionsAsync = ref.watch(classSessionsProvider);
    final orgTz = ref.watch(activeOrganizationProvider).asData?.value?.timezone;
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final rooms =
        ref.watch(orgRoomsProvider).asData?.value ?? const <RoomModel>[];
    final canManage = ref.watch(hasPermissionProvider('schedule.manage'));
    final isInstructorOnly = workspace.roleCode == 'instructor';

    final branchNames = <String, String>{
      for (final b in branches) b.id: b.name,
    };
    final branchTz = <String, String?>{
      for (final b in branches) b.id: b.timezone ?? orgTz,
    };
    final roomNames = <String, String>{for (final r in rooms) r.id: r.name};

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(classSessionsProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: RitmaPageContainer(
          maxWidth: 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RitmaSectionHeader(
                title: 'Schedules & Live Roster',
                subtitle: isInstructorOnly
                    ? 'Classes assigned directly to you and live attendance roster'
                    : 'Publish classes, assign instructors, monitor waitlists, and mark attendance',
                trailing: canManage
                    ? FilledButton.icon(
                        onPressed: () async {
                          final created = await showDialog<ClassSessionModel>(
                            context: context,
                            builder: (_) => const _CreateClassSessionDialog(),
                          );
                          if (created != null) {
                            RitmaSync.afterBookingMutation(
                              ref,
                              sessionId: created.id,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Session "${created.title}" published.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New Session'),
                      )
                    : IconButton(
                        tooltip: 'Refresh sessions',
                        onPressed: () => ref.invalidate(classSessionsProvider),
                        icon: const Icon(Icons.refresh),
                      ),
              ),
              const SizedBox(height: RitmaSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Upcoming'),
                      icon: Icon(Icons.upcoming_outlined, size: 16),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('History'),
                      icon: Icon(Icons.history, size: 16),
                    ),
                  ],
                  selected: <bool>{_showHistory},
                  onSelectionChanged: (s) {
                    if (s.isNotEmpty) setState(() => _showHistory = s.first);
                  },
                ),
              ),
              const SizedBox(height: RitmaSpacing.md),
              AsyncStateView<List<ClassSessionModel>>(
                value: sessionsAsync,
                isEmpty: (list) => _filterSessions(
                  list,
                  isInstructorOnly: isInstructorOnly,
                  currentUserId: currentUserId,
                ).isEmpty,
                emptyTitle: _showHistory
                    ? 'No past sessions'
                    : 'No upcoming sessions scheduled',
                emptyMessage: canManage
                    ? 'Tap New Session to publish a studio or gym class.'
                    : 'Assigned sessions will appear here once published.',
                onRetry: () => ref.invalidate(classSessionsProvider),
                data: (rawSessions) {
                  final sessions = _filterSessions(
                    rawSessions,
                    isInstructorOnly: isInstructorOnly,
                    currentUserId: currentUserId,
                  );

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth >= 820 ? 2 : 1;
                      const gap = RitmaSpacing.sm;
                      final cardWidth =
                          (constraints.maxWidth - (cols - 1) * gap) / cols;

                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: sessions.map((session) {
                          final cancelled =
                              session.status == SessionStatus.cancelled;
                          final ratio = session.capacity > 0
                              ? (session.confirmedCount / session.capacity)
                                    .clamp(0.0, 1.0)
                                    .toDouble()
                              : 0.0;
                          final roomLabel = roomNames[session.roomId];
                          final tz = branchTz[session.branchId] ?? orgTz;

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
                                          label:
                                              branchNames[session.branchId] ??
                                              'Branch',
                                          icon: Icons.storefront_outlined,
                                        ),
                                        RitmaStatusPill(
                                          label: cancelled
                                              ? 'CANCELLED'
                                              : '${session.confirmedCount}/${session.capacity} booked',
                                          tone: cancelled
                                              ? RitmaPillTone.danger
                                              : session.isFull
                                              ? RitmaPillTone.warning
                                              : RitmaPillTone.success,
                                        ),
                                        RitmaStatusPill(
                                          label: '${session.creditCost} credit',
                                          tone: RitmaPillTone.lime,
                                        ),
                                        if (session.waitlistEnabled &&
                                            !cancelled)
                                          const RitmaStatusPill(
                                            label: 'Waitlist ON',
                                            icon: Icons.queue_outlined,
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
                                      '${RitmaTimezone.formatDateTime(session.startsAt, tz)}'
                                      '${session.instructorDisplayName.isNotEmpty ? ' • ${session.instructorDisplayName}' : ''}'
                                      '${roomLabel != null ? ' • $roomLabel' : ''}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    if (!cancelled) ...[
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
                                    ],
                                    const SizedBox(height: RitmaSpacing.sm),
                                    Wrap(
                                      spacing: RitmaSpacing.xs,
                                      runSpacing: RitmaSpacing.xs,
                                      children: [
                                        FilledButton.tonalIcon(
                                          onPressed: () async {
                                            await showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (_) =>
                                                  _SessionRosterSheet(
                                                    session: session,
                                                  ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.checklist_outlined,
                                            size: 18,
                                          ),
                                          label: const Text('Live Roster'),
                                        ),
                                        if (canManage && !cancelled) ...[
                                          OutlinedButton.icon(
                                            onPressed: () async {
                                              final updated =
                                                  await showDialog<
                                                    ClassSessionModel
                                                  >(
                                                    context: context,
                                                    builder: (_) =>
                                                        _EditClassSessionDialog(
                                                          session: session,
                                                        ),
                                                  );
                                              if (updated != null &&
                                                  context.mounted) {
                                                RitmaSync.afterBookingMutation(
                                                  ref,
                                                  sessionId: updated.id,
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Session "${updated.title}" updated.',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                            ),
                                            label: const Text('Edit'),
                                          ),
                                          OutlinedButton(
                                            onPressed: () => _cancelSession(
                                              context,
                                              orgId: workspace.organizationId,
                                              sessionId: session.id,
                                            ),
                                            child: const Text('Cancel Session'),
                                          ),
                                        ],
                                      ],
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

  List<ClassSessionModel> _filterSessions(
    List<ClassSessionModel> list, {
    required bool isInstructorOnly,
    required String? currentUserId,
  }) {
    final now = DateTime.now().toUtc();
    return list.where((s) {
      if (isInstructorOnly &&
          currentUserId != null &&
          s.instructorUserId != currentUserId) {
        return false;
      }
      final isPast = !s.endsAt.toUtc().isAfter(now);
      return _showHistory ? isPast : !isPast;
    }).toList();
  }

  Future<void> _cancelSession(
    BuildContext context, {
    required String orgId,
    required String sessionId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Class Session?'),
        content: const Text(
          'All confirmed attendees will be refunded automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cancel Session'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final repo = ref.read(bookingRepositoryProvider);
    if (repo == null) {
      return;
    }
    final res = await repo.cancelClassSession(
      orgId: orgId,
      sessionId: sessionId,
    );
    if (!context.mounted) {
      return;
    }
    res.when(
      success: (_) {
        RitmaSync.afterBookingMutation(ref, sessionId: sessionId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session cancelled & credits refunded.'),
          ),
        );
      },
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}

class _SessionRosterSheet extends ConsumerWidget {
  const _SessionRosterSheet({required this.session});

  final ClassSessionModel session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final rosterAsync = ref.watch(sessionRosterProvider(session.id));
    final canMark = ref.watch(hasPermissionProvider('attendance.mark'));
    final canManageBookings = ref.watch(
      hasPermissionProvider('booking.manage'),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(RitmaSpacing.md),
            child: RitmaSectionHeader(
              title: session.title,
              subtitle:
                  'Roster (${session.confirmedCount}/${session.capacity} confirmed)',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canManageBookings &&
                      session.status == SessionStatus.scheduled &&
                      workspace != null)
                    Padding(
                      padding: const EdgeInsets.only(right: RitmaSpacing.xs),
                      child: FilledButton.tonalIcon(
                        onPressed: () async {
                          final booked = await showDialog<bool>(
                            context: context,
                            builder: (_) => _FrontDeskBookMemberDialog(
                              orgId: workspace.organizationId,
                              sessionId: session.id,
                            ),
                          );
                          if (booked == true && context.mounted) {
                            RitmaSync.afterBookingMutation(
                              ref,
                              sessionId: session.id,
                            );
                          }
                        },
                        icon: const Icon(Icons.person_add_outlined, size: 16),
                        label: const Text('Book Member'),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncStateView<List<SessionRosterEntry>>(
              value: rosterAsync,
              isEmpty: (list) => list.isEmpty,
              emptyTitle: 'No members booked yet',
              emptyMessage: 'Confirmed and waitlisted members appear here.',
              onRetry: () => ref.invalidate(sessionRosterProvider(session.id)),
              data: (entries) => ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(RitmaSpacing.md),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: RitmaSpacing.xs),
                    child: Padding(
                      padding: const EdgeInsets.all(RitmaSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${entry.memberDisplayName} (${entry.memberCode})',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              RitmaStatusPill(
                                label: entry.status == BookingStatus.waitlisted
                                    ? 'WAITLIST #${entry.waitlistPosition ?? '-'}'
                                    : entry.attendanceStatus.displayLabel
                                          .toUpperCase(),
                                tone:
                                    entry.attendanceStatus ==
                                        AttendanceStatus.checkedIn
                                    ? RitmaPillTone.success
                                    : entry.attendanceStatus ==
                                          AttendanceStatus.noShow
                                    ? RitmaPillTone.danger
                                    : entry.status == BookingStatus.waitlisted
                                    ? RitmaPillTone.warning
                                    : RitmaPillTone.neutral,
                              ),
                            ],
                          ),
                          if (workspace != null &&
                              ((canMark &&
                                      entry.status ==
                                          BookingStatus.confirmed) ||
                                  (canManageBookings &&
                                      (entry.status ==
                                              BookingStatus.confirmed ||
                                          entry.status ==
                                              BookingStatus.waitlisted)))) ...[
                            const SizedBox(height: RitmaSpacing.xs),
                            Wrap(
                              spacing: RitmaSpacing.xs,
                              children: [
                                if (canMark &&
                                    entry.status ==
                                        BookingStatus.confirmed) ...[
                                  OutlinedButton.icon(
                                    onPressed: () => _mark(
                                      context,
                                      ref,
                                      orgId: workspace.organizationId,
                                      bookingId: entry.bookingId,
                                      status: AttendanceStatus.checkedIn,
                                    ),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Checked In'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () => _mark(
                                      context,
                                      ref,
                                      orgId: workspace.organizationId,
                                      bookingId: entry.bookingId,
                                      status: AttendanceStatus.noShow,
                                    ),
                                    icon: const Icon(
                                      Icons.person_off_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('No Show'),
                                  ),
                                ],
                                if (canManageBookings &&
                                    (entry.status == BookingStatus.confirmed ||
                                        entry.status ==
                                            BookingStatus.waitlisted))
                                  TextButton.icon(
                                    onPressed: () => _cancelMemberBooking(
                                      context,
                                      ref,
                                      orgId: workspace.organizationId,
                                      bookingId: entry.bookingId,
                                    ),
                                    icon: const Icon(
                                      Icons.cancel_outlined,
                                      size: 16,
                                    ),
                                    label: const Text('Cancel Booking'),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mark(
    BuildContext context,
    WidgetRef ref, {
    required String orgId,
    required String bookingId,
    required AttendanceStatus status,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    if (repo == null) return;
    final res = await repo.markAttendance(
      orgId: orgId,
      bookingId: bookingId,
      attendanceStatus: status,
    );
    if (!context.mounted) return;
    res.when(
      success: (_) =>
          RitmaSync.afterBookingMutation(ref, sessionId: session.id),
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _cancelMemberBooking(
    BuildContext context,
    WidgetRef ref, {
    required String orgId,
    required String bookingId,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    if (repo == null) return;
    final res = await repo.cancelClassBooking(
      orgId: orgId,
      bookingId: bookingId,
      reason: 'Cancelled at desk',
    );
    if (!context.mounted) return;
    res.when(
      success: (out) {
        RitmaSync.afterBookingMutation(ref, sessionId: session.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              out.refundedCredits > 0
                  ? 'Booking cancelled & refunded ${out.refundedCredits} credit(s).'
                  : 'Booking cancelled.',
            ),
          ),
        );
      },
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}

class _FrontDeskBookMemberDialog extends ConsumerStatefulWidget {
  const _FrontDeskBookMemberDialog({
    required this.orgId,
    required this.sessionId,
  });

  final String orgId;
  final String sessionId;

  @override
  ConsumerState<_FrontDeskBookMemberDialog> createState() =>
      _FrontDeskBookMemberDialogState();
}

class _FrontDeskBookMemberDialogState
    extends ConsumerState<_FrontDeskBookMemberDialog> {
  String? _memberId;
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final members =
        (ref.watch(membersListProvider).asData?.value ?? const <MemberModel>[])
            .where((m) => m.status == MemberStatus.active)
            .toList();
    _memberId ??= members.firstOrNull?.id;

    return AlertDialog(
      title: const Text('Book Member Into Session'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: RitmaSpacing.sm),
            ],
            if (members.isEmpty)
              const Text('No active members available in roster.')
            else
              DropdownButtonFormField<String>(
                initialValue: _memberId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Member'),
                items: members
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(
                          '${m.fullName} (${m.memberCode})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _memberId = v),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_saving || _memberId == null)
              ? null
              : () async {
                  final repo = ref.read(bookingRepositoryProvider);
                  if (repo == null) return;
                  setState(() {
                    _saving = true;
                    _error = null;
                  });
                  final res = await repo.bookClassSession(
                    orgId: widget.orgId,
                    sessionId: widget.sessionId,
                    memberId: _memberId!,
                    idempotencyKey: const Uuid().v4(),
                  );
                  if (!context.mounted) return;
                  setState(() => _saving = false);
                  res.when(
                    success: (_) => Navigator.of(context).pop(true),
                    failure: (f) => setState(() => _error = f.message),
                  );
                },
          child: Text(_saving ? 'Booking...' : 'Confirm'),
        ),
      ],
    );
  }
}

class _CreateClassSessionDialog extends ConsumerStatefulWidget {
  const _CreateClassSessionDialog();

  @override
  ConsumerState<_CreateClassSessionDialog> createState() =>
      _CreateClassSessionDialogState();
}

class _CreateClassSessionDialogState
    extends ConsumerState<_CreateClassSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _instructorController = TextEditingController();
  final _newRoomController = TextEditingController(text: 'Main Studio');
  final _newClassTypeController = TextEditingController(text: 'General Class');
  final _capacityController = TextEditingController(text: '16');
  final _creditCostController = TextEditingController(text: '1');

  String? _branchId;
  String? _roomId;
  String? _classTypeId;
  String? _selectedInstructorUserId;
  int _startOffsetHours = 24;
  int _durationMinutes = 60;
  bool _waitlistEnabled = true;
  bool _saving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _instructorController.dispose();
    _newRoomController.dispose();
    _newClassTypeController.dispose();
    _capacityController.dispose();
    _creditCostController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(
        () => _errorMessage =
            'Please check the highlighted fields before publishing.',
      );
      return;
    }

    final branchesAsync = ref.read(orgBranchesProvider);
    final roomsAsync = ref.read(orgRoomsProvider);
    final classTypesAsync = ref.read(orgClassTypesProvider);
    if (branchesAsync.isLoading ||
        roomsAsync.isLoading ||
        classTypesAsync.isLoading) {
      setState(
        () => _errorMessage = 'Still loading branch, room, and class type data. Please wait a moment and try again.',
      );
      return;
    }

    final workspace = ref.read(activeWorkspaceProvider);
    final repo = ref.read(bookingRepositoryProvider);
    if (workspace == null || repo == null) {
      setState(
        () => _errorMessage =
            'Booking service is not available for the current session.',
      );
      return;
    }

    final capacity = int.tryParse(_capacityController.text.trim());
    final creditCost = int.tryParse(_creditCostController.text.trim());
    if (capacity == null ||
        capacity < 1 ||
        creditCost == null ||
        creditCost < 1) {
      setState(
        () => _errorMessage =
            'Capacity and credit cost must both be valid numbers (minimum 1).',
      );
      return;
    }

    final branchId = _branchId;
    if (branchId == null) {
      setState(
        () => _errorMessage =
            'Select an active branch before publishing this session.',
      );
      return;
    }

    final canCreateRoom =
        workspace.branchId == null && workspace.hasPermission('branch.manage');
    final canCreateClassType =
        workspace.branchId == null &&
        (workspace.hasPermission('schedule.manage') ||
            workspace.hasPermission('package.manage'));

    setState(() => _saving = true);
    try {
      var resolvedRoomId = _roomId;
      if (resolvedRoomId == null) {
        final orgRepo = ref.read(organizationRepositoryProvider);
        if (!canCreateRoom || orgRepo == null) {
          if (mounted) {
            setState(
              () => _errorMessage = 'No active room exists for this branch. Ask an Organization Owner or Admin to create a room first.',
            );
          }
          return;
        }
        final roomResult = await orgRepo.createRoom(
          orgId: workspace.organizationId,
          branchId: branchId,
          name: _newRoomController.text.trim(),
          roomType: 'studio',
          defaultCapacity: capacity,
        );
        if (!mounted) return;
        final createdRoom = roomResult.when(
          success: (room) => room,
          failure: (failure) {
            setState(
              () => _errorMessage = 'Unable to create room: ${failure.message}',
            );
            return null;
          },
        );
        if (createdRoom == null) return;
        resolvedRoomId = createdRoom.id;
        _roomId = createdRoom.id;
        ref.invalidate(orgRoomsProvider);
      }

      var resolvedClassTypeId = _classTypeId;
      if (resolvedClassTypeId == null) {
        final pkgRepo = ref.read(packageEntitlementRepositoryProvider);
        if (!canCreateClassType || pkgRepo == null) {
          if (mounted) {
            setState(
              () => _errorMessage = 'No active class type exists for this organization. Ask an Organization Owner or Admin to add one first.',
            );
          }
          return;
        }
        final typeResult = await pkgRepo.createClassType(
          orgId: workspace.organizationId,
          name: _newClassTypeController.text.trim(),
        );
        if (!mounted) return;
        final createdType = typeResult.when(
          success: (classType) => classType,
          failure: (failure) {
            setState(
              () => _errorMessage =
                  'Unable to create class type: ${failure.message}',
            );
            return null;
          },
        );
        if (createdType == null) return;
        resolvedClassTypeId = createdType.id;
        _classTypeId = createdType.id;
        ref.invalidate(orgClassTypesProvider);
      }

      final startsAt = DateTime.now().toUtc().add(
        Duration(hours: _startOffsetHours),
      );
      final endsAt = startsAt.add(Duration(minutes: _durationMinutes));
      final cutoff = startsAt.subtract(const Duration(hours: 2));

      final authState = ref.read(authControllerProvider).asData?.value;
      final currentUserId = switch (authState) {
        AuthenticatedSession(:final user) => user.id,
        _ => null,
      };
      final resolvedInstructorId =
          _selectedInstructorUserId ??
          (workspace.roleCode == 'instructor' ? currentUserId : null);

      final res = await repo.createClassSession(
        orgId: workspace.organizationId,
        branchId: branchId,
        roomId: resolvedRoomId,
        classTypeId: resolvedClassTypeId,
        title: _titleController.text.trim(),
        startsAt: startsAt,
        endsAt: endsAt,
        capacity: capacity,
        creditCost: creditCost,
        cancellationCutoffAt: cutoff,
        waitlistEnabled: _waitlistEnabled,
        instructorUserId: resolvedInstructorId,
        instructorDisplayName: _instructorController.text.trim(),
      );
      if (!mounted) return;
      res.when(
        success: (session) => Navigator.of(context).pop(session),
        failure: (failure) => setState(() => _errorMessage = failure.message),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _firstError(List<AsyncValue<dynamic>> values) {
    for (final value in values) {
      if (value.hasError) {
        return value.error.toString();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workspace = ref.watch(activeWorkspaceProvider);
    final branchesAsync = ref.watch(orgBranchesProvider);
    final roomsAsync = ref.watch(orgRoomsProvider);
    final classTypesAsync = ref.watch(orgClassTypesProvider);

    final branches = branchesAsync.asData?.value ?? const <BranchModel>[];
    final rooms = roomsAsync.asData?.value ?? const <RoomModel>[];
    final classTypes =
        classTypesAsync.asData?.value ?? const <ClassTypeModel>[];

    final isLoadingPrerequisites =
        branchesAsync.isLoading ||
        roomsAsync.isLoading ||
        classTypesAsync.isLoading;
    final prerequisiteError = _firstError([
      branchesAsync,
      roomsAsync,
      classTypesAsync,
    ]);

    _branchId ??= workspace?.branchId ?? branches.firstOrNull?.id;
    final instructors =
        ref.watch(assignableInstructorsProvider(_branchId)).asData?.value ??
        const <AssignableInstructor>[];

    final filteredRooms = rooms
        .where(
          (r) => r.isActive && (_branchId == null || r.branchId == _branchId),
        )
        .toList();
    if (_roomId == null || !filteredRooms.any((r) => r.id == _roomId)) {
      _roomId = filteredRooms.firstOrNull?.id;
    }
    final activeClassTypes = classTypes.where((ct) => ct.isActive).toList();
    if (_classTypeId == null ||
        !activeClassTypes.any((ct) => ct.id == _classTypeId)) {
      _classTypeId = activeClassTypes.firstOrNull?.id;
    }

    final canCreateRoom =
        workspace != null &&
        workspace.branchId == null &&
        workspace.hasPermission('branch.manage');
    final canCreateClassType =
        workspace != null &&
        workspace.branchId == null &&
        (workspace.hasPermission('schedule.manage') ||
            workspace.hasPermission('package.manage'));
    final visibleError = _errorMessage ?? prerequisiteError;

    return AlertDialog(
      title: const Text('New Class Session'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isLoadingPrerequisites) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                if (visibleError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(RitmaSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(RitmaRadius.md),
                      border: Border.all(color: theme.colorScheme.error),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visibleError,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        if (prerequisiteError != null) ...[
                          const SizedBox(height: RitmaSpacing.xs),
                          TextButton(
                            onPressed: _saving
                                ? null
                                : () {
                                    ref.invalidate(orgBranchesProvider);
                                    ref.invalidate(orgRoomsProvider);
                                    ref.invalidate(orgClassTypesProvider);
                                  },
                            child: const Text('Retry loading setup data'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Session Title'),
                  validator: (v) {
                    final trimmed = v?.trim() ?? '';
                    if (trimmed.length < 2) {
                      return 'Enter at least 2 characters';
                    }
                    if (trimmed.length > 120) {
                      return 'Maximum 120 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: RitmaSpacing.xs),
                if (workspace?.branchId == null && branches.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    key: ValueKey('branch-${_branchId ?? ''}'),
                    initialValue: _branchId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Branch'),
                    items: branches
                        .map(
                          (b) => DropdownMenuItem<String>(
                            value: b.id,
                            child: Text(
                              b.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _branchId = v;
                      _roomId = null;
                      _selectedInstructorUserId = null;
                      _errorMessage = null;
                    }),
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                ] else if (!branchesAsync.isLoading && _branchId == null) ...[
                  const _SetupNoticeBanner(
                    message: 'No active branch found for this organization. Create a branch first.',
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                ],
                if (filteredRooms.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    key: ValueKey('room-${_branchId ?? ''}-${_roomId ?? ''}'),
                    initialValue: _roomId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Room / Studio',
                    ),
                    items: filteredRooms
                        .map(
                          (r) => DropdownMenuItem<String>(
                            value: r.id,
                            child: Text(
                              '${r.name} (cap ${r.defaultCapacity})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _roomId = v;
                      _errorMessage = null;
                    }),
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                ] else if (!roomsAsync.isLoading) ...[
                  if (canCreateRoom)
                    TextFormField(
                      controller: _newRoomController,
                      decoration: const InputDecoration(
                        labelText: 'Room / Studio Name',
                        helperText: 'No rooms in this branch yet — created automatically on publish',
                      ),
                      validator: (v) {
                        final trimmed = v?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Room name is required';
                        }
                        if (trimmed.length > 80) {
                          return 'Maximum 80 characters';
                        }
                        return null;
                      },
                    )
                  else
                    const _SetupNoticeBanner(
                      message: 'No rooms are configured for this branch yet. Ask an Organization Owner or Admin to create a room in Branches & Rooms.',
                    ),
                  const SizedBox(height: RitmaSpacing.xs),
                ],
                if (activeClassTypes.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    key: ValueKey('class-type-${_classTypeId ?? ''}'),
                    initialValue: _classTypeId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Class Type'),
                    items: activeClassTypes
                        .map(
                          (ct) => DropdownMenuItem<String>(
                            value: ct.id,
                            child: Text(
                              ct.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _classTypeId = v;
                      _errorMessage = null;
                    }),
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                ] else if (!classTypesAsync.isLoading) ...[
                  if (canCreateClassType)
                    TextFormField(
                      controller: _newClassTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Class Type',
                        helperText: 'No class types yet — created automatically on publish',
                      ),
                      validator: (v) {
                        final trimmed = v?.trim() ?? '';
                        if (trimmed.length < 2) {
                          return 'Enter at least 2 characters';
                        }
                        if (trimmed.length > 80) {
                          return 'Maximum 80 characters';
                        }
                        return null;
                      },
                    )
                  else
                    const _SetupNoticeBanner(
                      message: 'No class types are configured yet. Ask an Organization Owner or Admin to add a class type.',
                    ),
                  const SizedBox(height: RitmaSpacing.xs),
                ],
                if (instructors.isNotEmpty) ...[
                  DropdownButtonFormField<String?>(
                    key: ValueKey(
                      'instr-${_selectedInstructorUserId ?? 'none'}',
                    ),
                    initialValue:
                        instructors.any(
                          (i) => i.userId == _selectedInstructorUserId,
                        )
                        ? _selectedInstructorUserId
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Assign Staff Instructor',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Custom / Unassigned Account'),
                      ),
                      ...instructors.map(
                        (i) => DropdownMenuItem<String?>(
                          value: i.userId,
                          child: Text(
                            '${i.displayName} (${i.roleDisplayName})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() {
                      _selectedInstructorUserId = val;
                      if (val != null) {
                        final picked = instructors
                            .where((i) => i.userId == val)
                            .firstOrNull;
                        if (picked != null) {
                          _instructorController.text = picked.displayName;
                        }
                      }
                    }),
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                ],
                TextFormField(
                  controller: _instructorController,
                  decoration: const InputDecoration(
                    labelText: 'Instructor Name',
                  ),
                ),
                const SizedBox(height: RitmaSpacing.xs),
                Builder(
                  builder: (context) {
                    final startField = DropdownButtonFormField<int>(
                      key: ValueKey('start-$_startOffsetHours'),
                      initialValue: _startOffsetHours,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Start'),
                      items: const [
                        DropdownMenuItem<int>(
                          value: 3,
                          child: Text(
                            'In 3 hours',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 24,
                          child: Text(
                            'Tomorrow',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 48,
                          child: Text(
                            'In 2 days',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _startOffsetHours = v);
                        }
                      },
                    );
                    final durationField = DropdownButtonFormField<int>(
                      key: ValueKey('duration-$_durationMinutes'),
                      initialValue: _durationMinutes,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Duration'),
                      items: const [
                        DropdownMenuItem<int>(
                          value: 45,
                          child: Text(
                            '45 min',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 60,
                          child: Text(
                            '60 min',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem<int>(
                          value: 75,
                          child: Text(
                            '75 min',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _durationMinutes = v);
                        }
                      },
                    );
                    final stackFields =
                        MediaQuery.textScalerOf(context).scale(14) > 16;
                    if (stackFields) {
                      return Column(
                        children: [
                          startField,
                          const SizedBox(height: RitmaSpacing.xs),
                          durationField,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: startField),
                        const SizedBox(width: RitmaSpacing.xs),
                        Expanded(child: durationField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: RitmaSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Capacity',
                        ),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          return (n == null || n < 1) ? 'Min 1' : null;
                        },
                      ),
                    ),
                    const SizedBox(width: RitmaSpacing.xs),
                    Expanded(
                      child: TextFormField(
                        controller: _creditCostController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Credit Cost',
                        ),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          return (n == null || n < 1) ? 'Min 1' : null;
                        },
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _waitlistEnabled,
                  onChanged: (v) => setState(() => _waitlistEnabled = v),
                  title: const Text('Enable Automatic Waitlist'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_saving || isLoadingPrerequisites) ? null : _submit,
          child: Text(_saving ? 'Publishing...' : 'Publish Session'),
        ),
      ],
    );
  }
}

class _EditClassSessionDialog extends ConsumerStatefulWidget {
  const _EditClassSessionDialog({required this.session});

  final ClassSessionModel session;

  @override
  ConsumerState<_EditClassSessionDialog> createState() =>
      _EditClassSessionDialogState();
}

class _EditClassSessionDialogState
    extends ConsumerState<_EditClassSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _instructorCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _creditCostCtrl;
  late String _roomId;
  late String _classTypeId;
  String? _selectedInstructorUserId;
  late bool _waitlistEnabled;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _titleCtrl = TextEditingController(text: s.title);
    _instructorCtrl = TextEditingController(text: s.instructorDisplayName);
    _capacityCtrl = TextEditingController(text: '${s.capacity}');
    _creditCostCtrl = TextEditingController(text: '${s.creditCost}');
    _roomId = s.roomId;
    _classTypeId = s.classTypeId;
    _selectedInstructorUserId = s.instructorUserId;
    _waitlistEnabled = s.waitlistEnabled;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _instructorCtrl.dispose();
    _capacityCtrl.dispose();
    _creditCostCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final repo = ref.read(bookingRepositoryProvider);
    if (repo == null) return;
    final cap = int.tryParse(_capacityCtrl.text.trim()) ?? 1;
    final cost = int.tryParse(_creditCostCtrl.text.trim()) ?? 1;
    setState(() {
      _saving = true;
      _error = null;
    });
    final res = await repo.updateClassSession(
      orgId: widget.session.organizationId,
      sessionId: widget.session.id,
      roomId: _roomId,
      classTypeId: _classTypeId,
      title: _titleCtrl.text,
      startsAt: widget.session.startsAt,
      endsAt: widget.session.endsAt,
      capacity: cap,
      creditCost: cost,
      cancellationCutoffAt: widget.session.cancellationCutoffAt,
      waitlistEnabled: _waitlistEnabled,
      instructorUserId: _selectedInstructorUserId,
      instructorDisplayName: _instructorCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    res.when(
      success: (updated) => Navigator.of(context).pop(updated),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms =
        (ref.watch(orgRoomsProvider).asData?.value ?? const <RoomModel>[])
            .where((r) => r.branchId == widget.session.branchId && r.isActive)
            .toList();
    final classTypes =
        (ref.watch(orgClassTypesProvider).asData?.value ??
                const <ClassTypeModel>[])
            .where((ct) => ct.isActive)
            .toList();
    final instructors =
        ref
            .watch(assignableInstructorsProvider(widget.session.branchId))
            .asData
            ?.value ??
        const <AssignableInstructor>[];

    return AlertDialog(
      title: const Text('Edit Class Session'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Session Title'),
                  validator: (v) =>
                      (v == null || v.trim().length < 2) ? 'Min 2 chars' : null,
                ),
                if (rooms.any((r) => r.id == _roomId)) ...[
                  const SizedBox(height: RitmaSpacing.xs),
                  DropdownButtonFormField<String>(
                    initialValue: _roomId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Room'),
                    items: rooms
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(r.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _roomId = v);
                    },
                  ),
                ],
                if (classTypes.any((c) => c.id == _classTypeId)) ...[
                  const SizedBox(height: RitmaSpacing.xs),
                  DropdownButtonFormField<String>(
                    initialValue: _classTypeId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Class Type'),
                    items: classTypes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _classTypeId = v);
                    },
                  ),
                ],
                if (instructors.isNotEmpty) ...[
                  const SizedBox(height: RitmaSpacing.xs),
                  DropdownButtonFormField<String?>(
                    initialValue:
                        instructors.any(
                          (i) => i.userId == _selectedInstructorUserId,
                        )
                        ? _selectedInstructorUserId
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Instructor',
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Unassigned Account'),
                      ),
                      ...instructors.map(
                        (i) => DropdownMenuItem<String?>(
                          value: i.userId,
                          child: Text(
                            '${i.displayName} (${i.roleDisplayName})',
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() {
                      _selectedInstructorUserId = val;
                      if (val != null) {
                        final match = instructors
                            .where((i) => i.userId == val)
                            .firstOrNull;
                        if (match != null) {
                          _instructorCtrl.text = match.displayName;
                        }
                      }
                    }),
                  ),
                ],
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _instructorCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Instructor Name',
                  ),
                ),
                const SizedBox(height: RitmaSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _capacityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Capacity',
                        ),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null ||
                              n < widget.session.confirmedCount ||
                              n < 1) {
                            return 'Min ${widget.session.confirmedCount}';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: RitmaSpacing.xs),
                    Expanded(
                      child: TextFormField(
                        controller: _creditCostCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Credit Cost',
                        ),
                      ),
                    ),
                  ],
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _waitlistEnabled,
                  onChanged: (v) => setState(() => _waitlistEnabled = v),
                  title: const Text('Enable Automatic Waitlist'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Saving...' : 'Save Changes'),
        ),
      ],
    );
  }
}

class _SetupNoticeBanner extends StatelessWidget {
  const _SetupNoticeBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final statusColors = context.statusColors;
    return Container(
      padding: const EdgeInsets.all(RitmaSpacing.sm),
      decoration: BoxDecoration(
        color: statusColors.warningBg,
        borderRadius: BorderRadius.circular(RitmaRadius.md),
        border: Border.all(color: statusColors.warningFg),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: statusColors.warningFg),
      ),
    );
  }
}

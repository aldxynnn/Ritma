import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_session_state.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../../organizations/domain/room_model.dart';
import '../../packages/application/package_providers.dart';
import '../../packages/domain/package_models.dart';
import '../application/booking_providers.dart';
import '../domain/booking_models.dart';

class OpsScheduleRosterView extends ConsumerWidget {
  const OpsScheduleRosterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    if (workspace == null) {
      return const SizedBox.shrink();
    }

    final sessionsAsync = ref.watch(classSessionsProvider);
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final canManage = ref.watch(hasPermissionProvider('schedule.manage'));
    final branchNames = <String, String>{
      for (final b in branches) b.id: b.name,
    };

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(classSessionsProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(RitmaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RitmaSectionHeader(
              title: 'Schedules & Live Roster',
              subtitle: 'Publish classes, monitor waitlists, and mark instructor attendance',
              trailing: canManage
                  ? FilledButton.icon(
                      onPressed: () async {
                        final created = await showDialog<bool>(
                          context: context,
                          builder: (_) => const _CreateClassSessionDialog(),
                        );
                        if (created == true) {
                          ref.invalidate(classSessionsProvider);
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
            const SizedBox(height: RitmaSpacing.md),
            AsyncStateView<List<ClassSessionModel>>(
              value: sessionsAsync,
              isEmpty: (list) => list.isEmpty,
              emptyTitle: 'No sessions scheduled',
              emptyMessage: 'Tap New Session to publish a studio or gym class.',
              onRetry: () => ref.invalidate(classSessionsProvider),
              data: (sessions) {
                final timeFmt = DateFormat.MMMEd().add_jm();
                return Column(
                  children: sessions.map((session) {
                    final cancelled = session.status == SessionStatus.cancelled;
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
                                ],
                              ),
                              const SizedBox(height: RitmaSpacing.xs),
                              Text(
                                session.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: RitmaSpacing.xxs),
                              Text(
                                '${timeFmt.format(session.startsAt.toLocal())}'
                                '${session.instructorDisplayName.isNotEmpty ? ' • ${session.instructorDisplayName}' : ''}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
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
                                        builder: (_) => _SessionRosterSheet(
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
                                  if (canManage && !cancelled)
                                    OutlinedButton(
                                      onPressed: () => _cancelSession(
                                        context,
                                        ref,
                                        orgId: workspace.organizationId,
                                        sessionId: session.id,
                                      ),
                                      child: const Text('Cancel Session'),
                                    ),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancelSession(
    BuildContext context,
    WidgetRef ref, {
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
        ref.invalidate(classSessionsProvider);
        ref.invalidate(memberBookingsProvider);
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
              trailing: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close),
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
                          if (canMark &&
                              workspace != null &&
                              entry.status == BookingStatus.confirmed) ...[
                            const SizedBox(height: RitmaSpacing.xs),
                            Wrap(
                              spacing: RitmaSpacing.xs,
                              children: [
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
    if (repo == null) {
      return;
    }
    final res = await repo.markAttendance(
      orgId: orgId,
      bookingId: bookingId,
      attendanceStatus: status,
    );
    if (!context.mounted) {
      return;
    }
    res.when(
      success: (_) {
        ref.invalidate(sessionRosterProvider(session.id));
        ref.invalidate(memberBookingsProvider);
      },
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
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
  final _capacityController = TextEditingController(text: '16');
  final _creditCostController = TextEditingController(text: '1');

  String? _branchId;
  String? _roomId;
  String? _classTypeId;
  int _startOffsetHours = 24;
  int _durationMinutes = 60;
  bool _waitlistEnabled = true;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _instructorController.dispose();
    _capacityController.dispose();
    _creditCostController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final workspace = ref.read(activeWorkspaceProvider);
    final repo = ref.read(bookingRepositoryProvider);
    if (workspace == null ||
        repo == null ||
        _branchId == null ||
        _roomId == null ||
        _classTypeId == null) {
      return;
    }
    setState(() => _saving = true);
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

    final res = await repo.createClassSession(
      orgId: workspace.organizationId,
      branchId: _branchId!,
      roomId: _roomId!,
      classTypeId: _classTypeId!,
      title: _titleController.text.trim(),
      startsAt: startsAt,
      endsAt: endsAt,
      capacity: int.parse(_capacityController.text.trim()),
      creditCost: int.parse(_creditCostController.text.trim()),
      cancellationCutoffAt: cutoff,
      waitlistEnabled: _waitlistEnabled,
      instructorUserId: workspace.roleCode == 'instructor'
          ? currentUserId
          : null,
      instructorDisplayName: _instructorController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    res.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final rooms =
        ref.watch(orgRoomsProvider).asData?.value ?? const <RoomModel>[];
    final classTypes =
        ref.watch(orgClassTypesProvider).asData?.value ??
        const <ClassTypeModel>[];

    _branchId ??= workspace?.branchId ?? branches.firstOrNull?.id;
    final filteredRooms = _branchId == null
        ? rooms
        : rooms.where((r) => r.branchId == _branchId).toList();
    if (_roomId == null || !filteredRooms.any((r) => r.id == _roomId)) {
      _roomId = filteredRooms.firstOrNull?.id;
    }
    _classTypeId ??= classTypes.firstOrNull?.id;

    return AlertDialog(
      title: const Text('New Class Session'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Session Title'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: RitmaSpacing.xs),
                if (workspace?.branchId == null && branches.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _branchId,
                    decoration: const InputDecoration(labelText: 'Branch'),
                    items: branches
                        .map(
                          (b) => DropdownMenuItem<String>(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _branchId = v;
                      _roomId = null;
                    }),
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                ],
                if (filteredRooms.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _roomId,
                    decoration: const InputDecoration(
                      labelText: 'Room / Studio',
                    ),
                    items: filteredRooms
                        .map(
                          (r) => DropdownMenuItem<String>(
                            value: r.id,
                            child: Text('${r.name} (cap ${r.defaultCapacity})'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _roomId = v),
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                ],
                if (classTypes.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _classTypeId,
                    decoration: const InputDecoration(labelText: 'Class Type'),
                    items: classTypes
                        .map(
                          (ct) => DropdownMenuItem<String>(
                            value: ct.id,
                            child: Text(ct.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _classTypeId = v),
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _startOffsetHours,
                        decoration: const InputDecoration(labelText: 'Start'),
                        items: const [
                          DropdownMenuItem<int>(
                            value: 3,
                            child: Text('In 3 hours'),
                          ),
                          DropdownMenuItem<int>(
                            value: 24,
                            child: Text('Tomorrow'),
                          ),
                          DropdownMenuItem<int>(
                            value: 48,
                            child: Text('In 2 days'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _startOffsetHours = v);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: RitmaSpacing.xs),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _durationMinutes,
                        decoration: const InputDecoration(
                          labelText: 'Duration',
                        ),
                        items: const [
                          DropdownMenuItem<int>(
                            value: 45,
                            child: Text('45 min'),
                          ),
                          DropdownMenuItem<int>(
                            value: 60,
                            child: Text('60 min'),
                          ),
                          DropdownMenuItem<int>(
                            value: 75,
                            child: Text('75 min'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _durationMinutes = v);
                          }
                        },
                      ),
                    ),
                  ],
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
                          final n = int.tryParse(v ?? '');
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
                          final n = int.tryParse(v ?? '');
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
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Publishing...' : 'Publish Session'),
        ),
      ],
    );
  }
}

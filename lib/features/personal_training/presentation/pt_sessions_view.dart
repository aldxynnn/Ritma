import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/state/ritma_sync.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/utils/ritma_timezone.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_session_state.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../application/pt_providers.dart';
import '../domain/pt_models.dart';

class PtSessionsView extends ConsumerWidget {
  const PtSessionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    if (workspace == null) {
      return const SizedBox.shrink();
    }

    final authState = ref.watch(authControllerProvider).asData?.value;
    final currentUserId = switch (authState) {
      AuthenticatedSession(:final user) => user.id,
      _ => null,
    };

    final trainersAsync = ref.watch(orgTrainersProvider);
    final sessionsAsync = ref.watch(ptSessionsProvider);
    final orgTz = ref.watch(activeOrganizationProvider).asData?.value?.timezone;
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final branchTzMap = <String, String?>{
      for (final b in branches) b.id: b.timezone ?? orgTz,
    };

    final isPersonalTrainer = workspace.roleCode == 'personal_trainer';
    final canManagePt = ref.watch(hasPermissionProvider('pt.manage'));
    final canManageOpsSchedule =
        ref.watch(hasPermissionProvider('schedule.manage')) ||
        ref.watch(hasPermissionProvider('booking.manage'));
    final canBookPt =
        workspace.memberId != null || canManagePt || canManageOpsSchedule;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(orgTrainersProvider);
        ref.invalidate(ptSessionsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: RitmaPageContainer(
          maxWidth: 1200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RitmaSectionHeader(
                title: 'Personal Training',
                subtitle:
                    '1-on-1 coaching sessions backed strictly by PT Credits',
                trailing: canBookPt
                    ? FilledButton.icon(
                        onPressed: () async {
                          final booked = await showDialog<bool>(
                            context: context,
                            builder: (_) => const _BookPtSessionDialog(),
                          );
                          if (booked == true) {
                            RitmaSync.afterPtMutation(ref);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('PT session booked.'),
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Book PT'),
                      )
                    : null,
              ),
              const SizedBox(height: RitmaSpacing.md),
              Text(
                'Active Trainers',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: RitmaSpacing.xs),
              AsyncStateView<List<TrainerProfileModel>>(
                value: trainersAsync,
                isEmpty: (list) => list.isEmpty,
                emptyTitle: 'No trainers active yet',
                emptyMessage: 'Active coach profiles configured for your organization appear here.',
                onRetry: () => ref.invalidate(orgTrainersProvider),
                data: (trainers) => Column(
                  children: trainers
                      .map(
                        (trainer) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: RitmaSpacing.xs,
                          ),
                          child: Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.fitness_center_outlined,
                              ),
                              title: Text(
                                trainer.displayName.isNotEmpty
                                    ? trainer.displayName
                                    : 'Trainer ${trainer.id.substring(0, 8)}',
                              ),
                              subtitle: Text(
                                [
                                  if (trainer.specialties.isNotEmpty)
                                    trainer.specialties.join(' • '),
                                  if (trainer.bio.isNotEmpty) trainer.bio,
                                ].join('\n'),
                              ),
                              trailing: RitmaStatusPill(
                                label: '${trainer.defaultCreditCost} PT credit',
                                tone: RitmaPillTone.lime,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: RitmaSpacing.lg),
              RitmaSectionHeader(
                title: 'Scheduled & Completed Sessions',
                subtitle: isPersonalTrainer
                    ? 'Scoped strictly to your assigned coaching sessions'
                    : null,
                trailing: IconButton(
                  tooltip: 'Refresh PT sessions',
                  onPressed: () => ref.invalidate(ptSessionsProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ),
              const SizedBox(height: RitmaSpacing.xs),
              AsyncStateView<List<PtSessionModel>>(
                value: sessionsAsync,
                isEmpty: (list) => list.isEmpty,
                emptyTitle: 'No PT sessions booked yet',
                emptyMessage:
                    'Book a 1-on-1 training slot using active PT Credits.',
                onRetry: () => ref.invalidate(ptSessionsProvider),
                data: (sessions) {
                  final scopedSessions =
                      isPersonalTrainer && currentUserId != null
                      ? sessions
                            .where(
                              (s) =>
                                  s.trainerUserId == null ||
                                  s.trainerUserId == currentUserId,
                            )
                            .toList()
                      : sessions;

                  return Column(
                    children: scopedSessions.map((session) {
                      final tone = switch (session.status) {
                        PtSessionStatus.scheduled => RitmaPillTone.lime,
                        PtSessionStatus.completed => RitmaPillTone.success,
                        PtSessionStatus.cancelledEarly => RitmaPillTone.neutral,
                        PtSessionStatus.cancelledLate => RitmaPillTone.danger,
                        PtSessionStatus.noShow => RitmaPillTone.warning,
                      };
                      final trainerLabel = session.trainerDisplayName.isNotEmpty
                          ? session.trainerDisplayName
                          : 'Trainer';
                      final memberLabel = session.memberDisplayName.isNotEmpty
                          ? (session.memberCode.isNotEmpty
                                ? '${session.memberDisplayName} (${session.memberCode})'
                                : session.memberDisplayName)
                          : (session.memberCode.isNotEmpty
                                ? session.memberCode
                                : 'Member');

                      final isOwnTrainerSession =
                          currentUserId != null &&
                          session.trainerUserId == currentUserId;
                      final canActComplete =
                          session.status == PtSessionStatus.scheduled &&
                          (ref.watch(
                                hasPermissionProvider('schedule.manage'),
                              ) ||
                              (canManagePt &&
                                  (!isPersonalTrainer || isOwnTrainerSession)));
                      final canActCancel =
                          session.status == PtSessionStatus.scheduled &&
                          (canActComplete ||
                              canManageOpsSchedule ||
                              workspace.memberId == session.memberId);

                      final tz = branchTzMap[session.branchId] ?? orgTz;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: RitmaSpacing.sm),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(RitmaSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Wrap(
                                  spacing: RitmaSpacing.xs,
                                  runSpacing: RitmaSpacing.xs,
                                  children: [
                                    RitmaStatusPill(
                                      label: session.status.displayLabel,
                                      tone: tone,
                                    ),
                                    RitmaStatusPill(
                                      label: '${session.creditCost} PT credit',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: RitmaSpacing.xs),
                                Text(
                                  '$trainerLabel × $memberLabel',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: RitmaSpacing.xxs),
                                Text(
                                  '${RitmaTimezone.formatDateTime(session.startsAt, tz, includeZone: false)} – ${RitmaTimezone.formatTime(session.endsAt, tz, includeZone: true)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                if (session.notes != null &&
                                    session.notes!.isNotEmpty) ...[
                                  const SizedBox(height: RitmaSpacing.xxs),
                                  Text(
                                    'Notes: ${session.notes}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                                if (canActComplete || canActCancel) ...[
                                  const SizedBox(height: RitmaSpacing.sm),
                                  Wrap(
                                    spacing: RitmaSpacing.xs,
                                    runSpacing: RitmaSpacing.xs,
                                    children: [
                                      if (canActComplete)
                                        OutlinedButton.icon(
                                          onPressed: () => _completeSession(
                                            context,
                                            ref,
                                            orgId: workspace.organizationId,
                                            session: session,
                                          ),
                                          icon: const Icon(
                                            Icons.check_circle_outline,
                                            size: 18,
                                          ),
                                          label: const Text('Complete Session'),
                                        ),
                                      if (canActCancel)
                                        TextButton.icon(
                                          onPressed: () => _cancelSession(
                                            context,
                                            ref,
                                            orgId: workspace.organizationId,
                                            session: session,
                                          ),
                                          icon: const Icon(
                                            Icons.cancel_outlined,
                                            size: 18,
                                          ),
                                          label: const Text('Cancel Session'),
                                        ),
                                    ],
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
      ),
    );
  }

  Future<void> _completeSession(
    BuildContext context,
    WidgetRef ref, {
    required String orgId,
    required PtSessionModel session,
  }) async {
    final notes = await showDialog<String>(
      context: context,
      builder: (_) => const _CompletePtSessionDialog(),
    );
    if (notes == null || !context.mounted) {
      return;
    }

    final repo = ref.read(ptRepositoryProvider);
    if (repo == null) {
      return;
    }
    final res = await repo.completePtSession(
      orgId: orgId,
      ptSessionId: session.id,
      notes: notes.trim().isEmpty ? null : notes.trim(),
    );
    if (!context.mounted) {
      return;
    }
    res.when(
      success: (_) {
        RitmaSync.afterPtMutation(ref);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PT session marked completed.')),
        );
      },
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _cancelSession(
    BuildContext context,
    WidgetRef ref, {
    required String orgId,
    required PtSessionModel session,
  }) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelPtSessionDialog(),
    );
    if (reason == null || !context.mounted) {
      return;
    }

    final repo = ref.read(ptRepositoryProvider);
    if (repo == null) {
      return;
    }
    final res = await repo.cancelPtSession(
      orgId: orgId,
      ptSessionId: session.id,
      reason: reason.trim().isEmpty ? null : reason.trim(),
    );
    if (!context.mounted) {
      return;
    }
    res.when(
      success: (outcome) {
        RitmaSync.afterPtMutation(ref);
        final msg = outcome.refundedCredits > 0
            ? 'PT session cancelled. Refunded ${outcome.refundedCredits} PT credit(s).'
            : 'PT session cancelled.';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      },
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }
}

class _CompletePtSessionDialog extends StatefulWidget {
  const _CompletePtSessionDialog();

  @override
  State<_CompletePtSessionDialog> createState() =>
      _CompletePtSessionDialogState();
}

class _CompletePtSessionDialogState extends State<_CompletePtSessionDialog> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete PT Session'),
      content: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: 'Coaching Notes (optional)',
          hintText: 'Progressive overload targets or recovery notes',
        ),
        maxLines: 2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_notesController.text),
          child: const Text('Mark Completed'),
        ),
      ],
    );
  }
}

class _CancelPtSessionDialog extends StatefulWidget {
  const _CancelPtSessionDialog();

  @override
  State<_CancelPtSessionDialog> createState() => _CancelPtSessionDialogState();
}

class _CancelPtSessionDialogState extends State<_CancelPtSessionDialog> {
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel PT Session?'),
      content: TextField(
        controller: _reasonCtrl,
        decoration: const InputDecoration(
          labelText: 'Cancellation Reason (optional)',
          hintText: 'Client rescheduled, illness, coach unavailable',
        ),
        maxLines: 2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_reasonCtrl.text),
          child: const Text('Confirm Cancel'),
        ),
      ],
    );
  }
}

class _BookPtSessionDialog extends ConsumerStatefulWidget {
  const _BookPtSessionDialog();

  @override
  ConsumerState<_BookPtSessionDialog> createState() =>
      _BookPtSessionDialogState();
}

class _BookPtSessionDialogState extends ConsumerState<_BookPtSessionDialog> {
  final _searchCtrl = TextEditingController();
  String? _trainerId;
  String? _memberId;
  String _clientQuery = '';
  DateTime? _selectedWallDate;
  int _hourBranchLocal = 10;
  bool _saving = false;
  String? _inlineError;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(String? timezone) async {
    final today = RitmaTimezone.orgToday(timezone);
    final initial = _selectedWallDate ?? today.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(
        today.year,
        today.month,
        today.day,
      ).add(const Duration(days: 60)),
    );
    if (picked != null && mounted) {
      setState(
        () => _selectedWallDate = DateTime.utc(
          picked.year,
          picked.month,
          picked.day,
        ),
      );
    }
  }

  Future<void> _submit(
    List<TrainerProfileModel> trainers,
    List<BranchModel> branches,
    String? orgTimezone,
  ) async {
    final workspace = ref.read(activeWorkspaceProvider);
    final repo = ref.read(ptRepositoryProvider);
    final trainer = trainers.where((t) => t.id == _trainerId).firstOrNull;
    final memberId = workspace?.isOperationsSurface == false
        ? workspace?.memberId
        : _memberId;
    if (workspace == null || repo == null) {
      setState(
        () => _inlineError = 'PT booking service is unavailable right now.',
      );
      return;
    }
    if (trainer == null) {
      setState(() => _inlineError = 'Select an active trainer.');
      return;
    }
    if (memberId == null) {
      setState(() => _inlineError = 'Select a member for this PT session.');
      return;
    }

    final branchTz =
        branches
            .where((b) => b.id == trainer.homeBranchId)
            .firstOrNull
            ?.timezone ??
        orgTimezone;
    final wallDate =
        _selectedWallDate ??
        RitmaTimezone.orgToday(branchTz).add(const Duration(days: 1));
    final startsAt = RitmaTimezone.fromOrgWallClock(
      year: wallDate.year,
      month: wallDate.month,
      day: wallDate.day,
      hour: _hourBranchLocal,
      timezone: branchTz,
    );
    final endsAt = startsAt.add(const Duration(hours: 1));

    setState(() {
      _saving = true;
      _inlineError = null;
    });

    final res = await repo.bookPtSession(
      orgId: workspace.organizationId,
      branchId: trainer.homeBranchId,
      trainerId: trainer.id,
      memberId: memberId,
      startsAt: startsAt,
      endsAt: endsAt,
      creditCost: trainer.defaultCreditCost,
      idempotencyKey: const Uuid().v4(),
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    res.when(
      success: (_) {
        RitmaSync.afterPtMutation(ref);
        Navigator.of(context).pop(true);
      },
      failure: (failure) => setState(() => _inlineError = failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final authState = ref.watch(authControllerProvider).asData?.value;
    final currentUserId = switch (authState) {
      AuthenticatedSession(:final user) => user.id,
      _ => null,
    };
    final trainersAsync = ref.watch(orgTrainersProvider);
    final trainers =
        trainersAsync.asData?.value ?? const <TrainerProfileModel>[];
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final orgTz = ref.watch(activeOrganizationProvider).asData?.value?.timezone;

    final isPersonalTrainer = workspace?.roleCode == 'personal_trainer';
    final ownTrainer = isPersonalTrainer && currentUserId != null
        ? trainers.where((t) => t.userId == currentUserId).firstOrNull
        : null;

    if (isPersonalTrainer) {
      _trainerId = ownTrainer?.id;
    } else {
      _trainerId ??= trainers.firstOrNull?.id;
    }

    final selectedTrainer = trainers
        .where((t) => t.id == _trainerId)
        .firstOrNull;
    final selectedBranchTz = selectedTrainer != null
        ? (branches
                  .where((b) => b.id == selectedTrainer.homeBranchId)
                  .firstOrNull
                  ?.timezone ??
              orgTz)
        : orgTz;

    _selectedWallDate ??= RitmaTimezone.orgToday(selectedBranchTz)
        .add(const Duration(days: 1));

    final clientLookupAsync =
        (workspace?.isOperationsSurface == true && selectedTrainer != null)
        ? ref.watch(
            ptClientLookupProvider((
              branchId: selectedTrainer.homeBranchId,
              query: _clientQuery,
            )),
          )
        : const AsyncData<List<PtClientLookup>>(<PtClientLookup>[]);
    final clients = clientLookupAsync.asData?.value ?? const <PtClientLookup>[];
    if (workspace?.isOperationsSurface == true && clients.isNotEmpty) {
      if (_memberId == null || !clients.any((c) => c.id == _memberId)) {
        _memberId = clients.first.id;
      }
    }

    const slotHours = <int>[
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
    ];

    return AlertDialog(
      title: const Text('Book Personal Training'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_inlineError != null) ...[
                Container(
                  padding: const EdgeInsets.all(RitmaSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(RitmaRadius.md),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: Text(
                    _inlineError!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                const SizedBox(height: RitmaSpacing.sm),
              ],
              if (trainersAsync.isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: RitmaSpacing.sm),
              ] else if (isPersonalTrainer && ownTrainer == null)
                const Text(
                  'No active trainer profile is linked to your account yet. Contact a branch manager.',
                )
              else if (trainers.isEmpty)
                const Text('No active trainers available.')
              else if (isPersonalTrainer && ownTrainer != null)
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Trainer (Self)',
                  ),
                  child: Text(
                    '${ownTrainer.displayName} (${ownTrainer.defaultCreditCost} PT credit)',
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _trainerId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Trainer'),
                  items: trainers
                      .map(
                        (t) => DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(
                            t.displayName.isNotEmpty
                                ? '${t.displayName} (${t.defaultCreditCost} PT)'
                                : 'Trainer ${t.id.substring(0, 8)}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() {
                    _trainerId = v;
                    _memberId = null;
                  }),
                ),
              if (workspace?.isOperationsSurface == true &&
                  selectedTrainer != null) ...[
                const SizedBox(height: RitmaSpacing.xs),
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    labelText: 'Search Member (name or code)',
                    isDense: true,
                    suffixIcon: IconButton(
                      tooltip: 'Filter clients',
                      icon: const Icon(Icons.search, size: 18),
                      onPressed: () => setState(
                        () => _clientQuery = _searchCtrl.text.trim(),
                      ),
                    ),
                  ),
                  onChanged: (val) => setState(() => _clientQuery = val.trim()),
                ),
                const SizedBox(height: RitmaSpacing.xs),
                if (clientLookupAsync.isLoading)
                  const LinearProgressIndicator()
                else if (clients.isEmpty)
                  Text(
                    'No active clients match filter.',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  DropdownButtonFormField<String>(
                    key: ValueKey('pt-member-${_memberId ?? ''}'),
                    initialValue: _memberId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Member'),
                    items: clients
                        .map(
                          (m) => DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(
                              '${m.fullName} (${m.memberCode}) • ${m.availablePtCredits} PT cr',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _memberId = v),
                  ),
              ],
              const SizedBox(height: RitmaSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _saving ? null : () => _pickDate(selectedBranchTz),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText:
                              'Date (${RitmaTimezone.shortLabel(selectedBranchTz)})',
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            size: 18,
                          ),
                        ),
                        child: Text(
                          RitmaTimezone.formatDate(_selectedWallDate!, 'UTC'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: RitmaSpacing.xs),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _hourBranchLocal,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText:
                            'Start (${RitmaTimezone.shortLabel(selectedBranchTz)})',
                      ),
                      items: slotHours
                          .map(
                            (h) => DropdownMenuItem<int>(
                              value: h,
                              child: Text('${h.toString().padLeft(2, '0')}:00'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _hourBranchLocal = v);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: (_saving || selectedTrainer == null)
              ? null
              : () => _submit(trainers, branches, orgTz),
          child: Text(_saving ? 'Booking...' : 'Confirm Booking'),
        ),
      ],
    );
  }
}

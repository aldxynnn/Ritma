import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../members/application/member_providers.dart';
import '../../members/domain/member_model.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../../packages/application/package_providers.dart';
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

    final trainersAsync = ref.watch(orgTrainersProvider);
    final sessionsAsync = ref.watch(ptSessionsProvider);
    final canManagePt = ref.watch(hasPermissionProvider('pt.manage'));
    final canBookPt =
        workspace.memberId != null ||
        canManagePt ||
        ref.watch(hasPermissionProvider('booking.manage'));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(orgTrainersProvider);
        ref.invalidate(ptSessionsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(RitmaSpacing.md),
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
                          ref.invalidate(ptSessionsProvider);
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
                        padding: const EdgeInsets.only(bottom: RitmaSpacing.xs),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.fitness_center_outlined),
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
                final timeFmt = DateFormat.MMMEd().add_jm();
                return Column(
                  children: sessions.map((session) {
                    final tone = switch (session.status) {
                      PtSessionStatus.scheduled => RitmaPillTone.lime,
                      PtSessionStatus.completed => RitmaPillTone.success,
                      PtSessionStatus.cancelledEarly => RitmaPillTone.neutral,
                      PtSessionStatus.cancelledLate => RitmaPillTone.danger,
                      PtSessionStatus.noShow => RitmaPillTone.warning,
                    };
                    final trainerLabel = session.trainerDisplayName.isNotEmpty
                        ? session.trainerDisplayName
                        : 'Trainer ${session.trainerId.substring(0, 8)}';
                    final memberLabel = session.memberDisplayName.isNotEmpty
                        ? session.memberDisplayName
                        : 'Member ${session.memberId.substring(0, 8)}';

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
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: RitmaSpacing.xxs),
                              Text(
                                '${timeFmt.format(session.startsAt.toLocal())} – ${DateFormat.jm().format(session.endsAt.toLocal())}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (session.notes != null &&
                                  session.notes!.isNotEmpty) ...[
                                const SizedBox(height: RitmaSpacing.xxs),
                                Text(
                                  'Notes: ${session.notes}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              if (canManagePt &&
                                  session.status ==
                                      PtSessionStatus.scheduled) ...[
                                const SizedBox(height: RitmaSpacing.sm),
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

  Future<void> _completeSession(
    BuildContext context,
    WidgetRef ref, {
    required String orgId,
    required PtSessionModel session,
  }) async {
    final notesController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete PT Session'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Coaching Notes (optional)',
            hintText: 'Progressive overload targets or recovery notes',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Mark Completed'),
          ),
        ],
      ),
    );
    final notes = notesController.text;
    notesController.dispose();
    if (confirm != true || !context.mounted) {
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
        ref.invalidate(ptSessionsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PT session marked completed.')),
        );
      },
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
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
  String? _trainerId;
  String? _memberId;
  int _dayOffset = 1;
  int _hourBranchLocal = 10;
  bool _saving = false;

  Future<void> _submit(
    List<TrainerProfileModel> trainers,
    List<BranchModel> branches,
  ) async {
    final workspace = ref.read(activeWorkspaceProvider);
    final repo = ref.read(ptRepositoryProvider);
    final trainer = trainers.where((t) => t.id == _trainerId).firstOrNull;
    final memberId = workspace?.isOperationsSurface == false
        ? workspace?.memberId
        : _memberId;
    if (workspace == null ||
        repo == null ||
        trainer == null ||
        memberId == null) {
      return;
    }

    setState(() => _saving = true);
    final branchTz = branches
        .where((b) => b.id == trainer.homeBranchId)
        .firstOrNull
        ?.timezone;
    final tzOffset = branchTz == 'Asia/Jakarta'
        ? const Duration(hours: 7)
        : Duration.zero;
    final targetDay = DateTime.now().toUtc().add(Duration(days: _dayOffset));
    final startsAt = DateTime.utc(
      targetDay.year,
      targetDay.month,
      targetDay.day,
      _hourBranchLocal,
      0,
    ).subtract(tzOffset);
    final endsAt = startsAt.add(const Duration(hours: 1));

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
        ref.invalidate(memberWalletProvider(memberId));
        Navigator.of(context).pop(true);
      },
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final trainers =
        ref.watch(orgTrainersProvider).asData?.value ??
        const <TrainerProfileModel>[];
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final members = workspace?.isOperationsSurface == true
        ? (ref.watch(membersListProvider).asData?.value ??
              const <MemberModel>[])
        : const <MemberModel>[];

    _trainerId ??= trainers.firstOrNull?.id;
    if (workspace?.isOperationsSurface == true) {
      _memberId ??= members.firstOrNull?.id;
    }

    return AlertDialog(
      title: const Text('Book Personal Training'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trainers.isEmpty)
                const Text('No active trainers available.')
              else
                DropdownButtonFormField<String>(
                  initialValue: _trainerId,
                  decoration: const InputDecoration(labelText: 'Trainer'),
                  items: trainers
                      .map(
                        (t) => DropdownMenuItem<String>(
                          value: t.id,
                          child: Text(
                            t.displayName.isNotEmpty
                                ? '${t.displayName} (${t.defaultCreditCost} PT)'
                                : 'Trainer ${t.id.substring(0, 8)}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _trainerId = v),
                ),
              if (workspace?.isOperationsSurface == true &&
                  members.isNotEmpty) ...[
                const SizedBox(height: RitmaSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue: _memberId,
                  decoration: const InputDecoration(labelText: 'Member'),
                  items: members
                      .map(
                        (m) => DropdownMenuItem<String>(
                          value: m.id,
                          child: Text('${m.fullName} (${m.memberCode})'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _memberId = v),
                ),
              ],
              const SizedBox(height: RitmaSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _dayOffset,
                      decoration: const InputDecoration(labelText: 'Day'),
                      items: const [
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Text('Tomorrow'),
                        ),
                        DropdownMenuItem<int>(
                          value: 2,
                          child: Text('In 2 Days'),
                        ),
                        DropdownMenuItem<int>(
                          value: 3,
                          child: Text('In 3 Days'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _dayOffset = v);
                      },
                    ),
                  ),
                  const SizedBox(width: RitmaSpacing.xs),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _hourBranchLocal,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                      ),
                      items: const [
                        DropdownMenuItem<int>(value: 9, child: Text('09:00')),
                        DropdownMenuItem<int>(value: 10, child: Text('10:00')),
                        DropdownMenuItem<int>(value: 14, child: Text('14:00')),
                        DropdownMenuItem<int>(value: 17, child: Text('17:00')),
                      ],
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
          onPressed: (_saving || trainers.isEmpty)
              ? null
              : () => _submit(trainers, branches),
          child: Text(_saving ? 'Booking...' : 'Confirm Booking'),
        ),
      ],
    );
  }
}

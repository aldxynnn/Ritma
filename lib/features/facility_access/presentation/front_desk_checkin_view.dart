import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/state/ritma_sync.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/theme/ritma_status_colors.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../application/facility_access_providers.dart';
import '../domain/facility_access_models.dart';
import 'qr_scanner_sheet.dart';

class FrontDeskCheckInView extends ConsumerStatefulWidget {
  const FrontDeskCheckInView({super.key});

  @override
  ConsumerState<FrontDeskCheckInView> createState() =>
      _FrontDeskCheckInViewState();
}

class _FrontDeskCheckInViewState extends ConsumerState<FrontDeskCheckInView> {
  final TextEditingController _qrController = TextEditingController();
  final TextEditingController _lookupController = TextEditingController();

  String? _selectedBranchId;
  bool _submitting = false;
  CheckInOutcome? _lastOutcome;
  List<CheckInMemberLookup> _lookupResults = const <CheckInMemberLookup>[];
  String? _lookupError;

  @override
  void dispose() {
    _qrController.dispose();
    _lookupController.dispose();
    super.dispose();
  }

  String? _resolveBranchId(String? workspaceBranchId, List<BranchModel> list) {
    if (workspaceBranchId != null && workspaceBranchId.isNotEmpty) {
      return workspaceBranchId;
    }
    final synced = ref.read(selectedCheckInBranchProvider);
    final candidate = _selectedBranchId ?? synced;
    if (candidate != null && list.any((b) => b.id == candidate)) {
      return candidate;
    }
    return list.isNotEmpty ? list.first.id : null;
  }

  Future<({bool allowed, String message, String? reasonCode})>
  _processQrTokenValue({
    required String orgId,
    required String branchId,
    required String rawToken,
  }) async {
    final token = rawToken.trim();
    final repo = ref.read(facilityAccessRepositoryProvider);
    if (repo == null) {
      return (
        allowed: false,
        message: 'Check-in service unavailable.',
        reasonCode: 'UNAVAILABLE',
      );
    }
    setState(() => _submitting = true);
    final result = await repo.validateAndCheckIn(
      orgId: orgId,
      branchId: branchId,
      qrToken: token,
      idempotencyKey: const Uuid().v4(),
    );
    if (!mounted) {
      return (allowed: false, message: 'Cancelled.', reasonCode: null);
    }
    setState(() => _submitting = false);
    return result.when(
      success: (outcome) {
        setState(() => _lastOutcome = outcome);
        if (outcome.allowed) {
          _qrController.clear();
          RitmaSync.afterCheckIn(ref);
        }
        return (
          allowed: outcome.allowed,
          message: outcome.allowed
              ? 'Check-in approved (${outcome.memberName ?? 'Member'})'
              : 'Denied: ${outcome.reasonCode}',
          reasonCode: outcome.reasonCode,
        );
      },
      failure: (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
        return (allowed: false, message: failure.message, reasonCode: 'ERROR');
      },
    );
  }

  Future<void> _submitQrCheckIn({
    required String orgId,
    required String branchId,
  }) async {
    final token = _qrController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter or scan a member QR token.')),
      );
      return;
    }
    await _processQrTokenValue(
      orgId: orgId,
      branchId: branchId,
      rawToken: token,
    );
  }

  Future<void> _openCameraScanner({
    required String orgId,
    required String branchId,
    required String branchName,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => QrScannerSheet(
        branchName: branchName,
        onScanToken: (token) => _processQrTokenValue(
          orgId: orgId,
          branchId: branchId,
          rawToken: token,
        ),
      ),
    );
  }

  Future<void> _searchMembers({
    required String orgId,
    required String branchId,
  }) async {
    final repo = ref.read(facilityAccessRepositoryProvider);
    if (repo == null) {
      return;
    }
    final result = await repo.lookupMembersForCheckIn(
      orgId: orgId,
      branchId: branchId,
      query: _lookupController.text.trim(),
    );
    if (!mounted) {
      return;
    }
    result.when(
      success: (list) => setState(() {
        _lookupResults = list;
        _lookupError = null;
      }),
      failure: (failure) => setState(() => _lookupError = failure.message),
    );
  }

  Future<void> _manualCheckIn({
    required String orgId,
    required String branchId,
    required String memberId,
    bool forceOverride = false,
  }) async {
    String? reason;
    if (forceOverride) {
      reason = await _promptOverrideReason();
      if (reason == null || !mounted) {
        return;
      }
    }
    final repo = ref.read(facilityAccessRepositoryProvider);
    if (repo == null) {
      return;
    }
    setState(() => _submitting = true);
    final result = await repo.manualCheckIn(
      orgId: orgId,
      branchId: branchId,
      memberId: memberId,
      idempotencyKey: const Uuid().v4(),
      forceOverride: forceOverride,
      reason: reason,
    );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    result.when(
      success: (outcome) {
        setState(() => _lastOutcome = outcome);
        if (outcome.allowed) {
          RitmaSync.afterCheckIn(ref);
        }
      },
      failure: (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  Future<String?> _promptOverrideReason() {
    return showDialog<String>(
      context: context,
      builder: (_) => const _OverrideReasonDialog(),
    );
  }

  Future<void> _checkOut({
    required String orgId,
    required String visitId,
  }) async {
    final repo = ref.read(facilityAccessRepositoryProvider);
    if (repo == null) {
      return;
    }
    final res = await repo.checkOutVisit(orgId: orgId, visitId: visitId);
    if (!mounted) {
      return;
    }
    res.when(
      success: (_) => RitmaSync.afterCheckIn(ref),
      failure: (failure) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspace = ref.watch(activeWorkspaceProvider);
    if (workspace == null) {
      return const SizedBox.shrink();
    }

    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final activeBranchId = _resolveBranchId(workspace.branchId, branches);
    final activeBranchName =
        branches.where((b) => b.id == activeBranchId).firstOrNull?.name ??
        'Branch';
    final canPerform = ref.watch(hasPermissionProvider('checkin.perform'));
    final canOverride = ref.watch(
      hasPermissionProvider('checkin.force_override'),
    );
    final visitsAsync = ref.watch(branchVisitsProvider);

    return SingleChildScrollView(
      child: RitmaPageContainer(
        maxWidth: 1200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const RitmaSectionHeader(
              title: 'Front-Desk Facility Check-In',
              subtitle: 'Scan rotating QR passes via camera or token, enforce entitlements, and monitor occupancy',
            ),
            const SizedBox(height: RitmaSpacing.md),
            if (workspace.branchId == null && branches.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                key: ValueKey('checkin-branch-${activeBranchId ?? ''}'),
                initialValue: activeBranchId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Check-In Branch',
                  prefixIcon: Icon(Icons.storefront_outlined),
                ),
                items: branches
                    .map(
                      (b) => DropdownMenuItem<String>(
                        value: b.id,
                        child: Text(b.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedBranchId = val);
                  ref
                      .read(selectedCheckInBranchProvider.notifier)
                      .setBranch(val);
                },
              ),
              const SizedBox(height: RitmaSpacing.md),
            ],
            if (_lastOutcome != null) ...[
              _OutcomeBanner(outcome: _lastOutcome!),
              const SizedBox(height: RitmaSpacing.md),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final twoColumn =
                    constraints.maxWidth >= 900 &&
                    canPerform &&
                    activeBranchId != null;

                final controlsPane = (canPerform && activeBranchId != null)
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(RitmaSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: RitmaSpacing.xs,
                                    runSpacing: RitmaSpacing.xs,
                                    children: [
                                      Text(
                                        'QR Pass Validation',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      FilledButton.tonalIcon(
                                        onPressed: _submitting
                                            ? null
                                            : () => _openCameraScanner(
                                                orgId: workspace.organizationId,
                                                branchId: activeBranchId,
                                                branchName: activeBranchName,
                                              ),
                                        icon: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Scan QR with Camera',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: RitmaSpacing.xs),
                                  TextField(
                                    controller: _qrController,
                                    decoration: const InputDecoration(
                                      labelText: 'Member QR Token',
                                      hintText:
                                          'Paste or scan token payload...',
                                      prefixIcon: Icon(Icons.qr_code_scanner),
                                    ),
                                    onSubmitted: (_) => _submitQrCheckIn(
                                      orgId: workspace.organizationId,
                                      branchId: activeBranchId,
                                    ),
                                  ),
                                  const SizedBox(height: RitmaSpacing.sm),
                                  FilledButton.icon(
                                    onPressed: _submitting
                                        ? null
                                        : () => _submitQrCheckIn(
                                            orgId: workspace.organizationId,
                                            branchId: activeBranchId,
                                          ),
                                    icon: const Icon(
                                      Icons.verified_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Validate & Check In'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: RitmaSpacing.md),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(RitmaSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Manual Member Lookup',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  const SizedBox(height: RitmaSpacing.xs),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _lookupController,
                                          decoration: const InputDecoration(
                                            labelText: 'Name or Member Code',
                                            prefixIcon: Icon(
                                              Icons.person_search_outlined,
                                            ),
                                          ),
                                          onSubmitted: (_) => _searchMembers(
                                            orgId: workspace.organizationId,
                                            branchId: activeBranchId,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: RitmaSpacing.xs),
                                      FilledButton(
                                        onPressed: _submitting
                                            ? null
                                            : () => _searchMembers(
                                                orgId: workspace.organizationId,
                                                branchId: activeBranchId,
                                              ),
                                        child: const Text('Search'),
                                      ),
                                    ],
                                  ),
                                  if (_lookupError != null) ...[
                                    const SizedBox(height: RitmaSpacing.xs),
                                    Text(
                                      _lookupError!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                    ),
                                  ],
                                  if (_lookupResults.isNotEmpty) ...[
                                    const SizedBox(height: RitmaSpacing.sm),
                                    ..._lookupResults.map(
                                      (member) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          const Divider(
                                            height: RitmaSpacing.md,
                                          ),
                                          Text(
                                            member.fullName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(
                                            height: RitmaSpacing.xxs,
                                          ),
                                          Text(
                                            '${member.memberCode} • ${member.status.toUpperCase()}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(
                                            height: RitmaSpacing.xs,
                                          ),
                                          Wrap(
                                            spacing: RitmaSpacing.xs,
                                            runSpacing: RitmaSpacing.xs,
                                            children: [
                                              OutlinedButton(
                                                onPressed: _submitting
                                                    ? null
                                                    : () => _manualCheckIn(
                                                        orgId: workspace
                                                            .organizationId,
                                                        branchId:
                                                            activeBranchId,
                                                        memberId: member.id,
                                                      ),
                                                style: OutlinedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal:
                                                            RitmaSpacing.sm,
                                                      ),
                                                  minimumSize: const Size(
                                                    0,
                                                    40,
                                                  ),
                                                ),
                                                child: const Text('Check In'),
                                              ),
                                              if (canOverride)
                                                FilledButton.tonal(
                                                  onPressed: _submitting
                                                      ? null
                                                      : () => _manualCheckIn(
                                                          orgId: workspace
                                                              .organizationId,
                                                          branchId:
                                                              activeBranchId,
                                                          memberId: member.id,
                                                          forceOverride: true,
                                                        ),
                                                  style: FilledButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal:
                                                              RitmaSpacing.sm,
                                                        ),
                                                    minimumSize: const Size(
                                                      0,
                                                      40,
                                                    ),
                                                  ),
                                                  child: const Text('Override'),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink();

                final visitsPane = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RitmaSectionHeader(
                      title: 'Recent Branch Visits',
                      subtitle: 'Live gate and reception check-in feed',
                      trailing: IconButton(
                        tooltip: 'Refresh visits',
                        onPressed: () => ref.invalidate(branchVisitsProvider),
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                    const SizedBox(height: RitmaSpacing.sm),
                    AsyncStateView<List<FacilityVisitModel>>(
                      value: visitsAsync,
                      isEmpty: (visits) => visits.isEmpty,
                      emptyTitle: 'No visits recorded yet',
                      emptyMessage:
                          'Validated check-ins appear here in real time.',
                      onRetry: () => ref.invalidate(branchVisitsProvider),
                      data: (visits) {
                        final fmt = DateFormat.jm();
                        final activeCount = visits
                            .where((v) => v.checkedOutAt == null)
                            .length;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              spacing: RitmaSpacing.xs,
                              runSpacing: RitmaSpacing.xs,
                              children: [
                                RitmaStatusPill(
                                  label: '$activeCount Active on Floor',
                                  icon: Icons.sensors,
                                  tone: activeCount > 0
                                      ? RitmaPillTone.lime
                                      : RitmaPillTone.neutral,
                                ),
                                RitmaStatusPill(
                                  label: '${visits.length} Recent Visits',
                                  icon: Icons.history,
                                ),
                              ],
                            ),
                            const SizedBox(height: RitmaSpacing.sm),
                            ...visits.map(
                              (visit) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: RitmaSpacing.xs,
                                ),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      RitmaSpacing.md,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          visit.checkInMethod == 'qr'
                                              ? Icons.qr_code_2
                                              : Icons.badge_outlined,
                                        ),
                                        const SizedBox(width: RitmaSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (visit.memberName != null &&
                                                        visit.memberName!
                                                            .trim()
                                                            .isNotEmpty)
                                                    ? visit.memberName!
                                                    : 'Member ${visit.memberId.substring(0, 8)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(
                                                height: RitmaSpacing.xxs,
                                              ),
                                              Text(
                                                'In ${fmt.format(visit.checkedInAt.toLocal())}'
                                                '${visit.checkedOutAt != null ? ' • Out ${fmt.format(visit.checkedOutAt!.toLocal())}' : ' • Active inside'}'
                                                '${visit.overrideReason != null ? '\nOverride: ${visit.overrideReason}' : ''}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: RitmaSpacing.sm),
                                        visit.checkedOutAt == null && canPerform
                                            ? OutlinedButton(
                                                onPressed: () => _checkOut(
                                                  orgId:
                                                      workspace.organizationId,
                                                  visitId: visit.id,
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal:
                                                            RitmaSpacing.sm,
                                                      ),
                                                  minimumSize: const Size(
                                                    0,
                                                    40,
                                                  ),
                                                ),
                                                child: const Text('Check Out'),
                                              )
                                            : RitmaStatusPill(
                                                label:
                                                    visit.checkedOutAt == null
                                                    ? 'IN FACILITY'
                                                    : 'CHECKED OUT',
                                                tone: visit.checkedOutAt == null
                                                    ? RitmaPillTone.success
                                                    : RitmaPillTone.neutral,
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );

                if (twoColumn) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: controlsPane),
                      const SizedBox(width: RitmaSpacing.md),
                      Expanded(flex: 6, child: visitsPane),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (canPerform && activeBranchId != null) ...[
                      controlsPane,
                      const SizedBox(height: RitmaSpacing.lg),
                    ],
                    visitsPane,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeBanner extends StatelessWidget {
  const _OutcomeBanner({required this.outcome});

  final CheckInOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final status = context.statusColors;
    final bg = outcome.allowed ? status.successBg : status.dangerBg;
    final fg = outcome.allowed ? status.successFg : status.dangerFg;

    return Container(
      padding: const EdgeInsets.all(RitmaSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(RitmaRadius.md),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            outcome.allowed ? Icons.verified_outlined : Icons.block,
            color: fg,
          ),
          const SizedBox(width: RitmaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outcome.allowed
                      ? 'ACCESS GRANTED — ${outcome.memberName ?? 'Member'}'
                      : 'ACCESS DENIED — ${outcome.reasonCode}',
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: RitmaSpacing.xxs),
                Text(
                  'Reason: ${outcome.reasonCode}'
                  '${outcome.idempotentReplay ? ' (idempotent replay)' : ''}'
                  '${outcome.entitlementValidUntil != null ? ' • Pass valid until ${DateFormat.yMMMd().format(outcome.entitlementValidUntil!.toLocal())}' : ''}',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: fg),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverrideReasonDialog extends StatefulWidget {
  const _OverrideReasonDialog();

  @override
  State<_OverrideReasonDialog> createState() => _OverrideReasonDialogState();
}

class _OverrideReasonDialogState extends State<_OverrideReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manager Override Check-In'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Audit reason (required)',
            hintText: 'e.g. Member pass renewal pending reception payment',
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().length < 5) {
              return 'Provide at least 5 characters for audit trail.';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_controller.text.trim());
            }
          },
          child: const Text('Confirm Override'),
        ),
      ],
    );
  }
}

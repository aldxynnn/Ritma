import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/theme/ritma_status_colors.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../application/facility_access_providers.dart';
import '../domain/facility_access_models.dart';

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
    if (_selectedBranchId != null &&
        list.any((b) => b.id == _selectedBranchId)) {
      return _selectedBranchId;
    }
    return list.isNotEmpty ? list.first.id : null;
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
    final repo = ref.read(facilityAccessRepositoryProvider);
    if (repo == null) {
      return;
    }
    setState(() => _submitting = true);
    final result = await repo.validateAndCheckIn(
      orgId: orgId,
      branchId: branchId,
      qrToken: token,
      idempotencyKey: const Uuid().v4(),
    );
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);
    result.when(
      success: (outcome) {
        setState(() => _lastOutcome = outcome);
        if (outcome.allowed) {
          _qrController.clear();
          ref.invalidate(branchVisitsProvider);
        }
      },
      failure: (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
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
          ref.invalidate(branchVisitsProvider);
        }
      },
      failure: (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
    );
  }

  Future<String?> _promptOverrideReason() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manager Override Check-In'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(controller.text.trim());
              }
            },
            child: const Text('Confirm Override'),
          ),
        ],
      ),
    );
    controller.dispose();
    return confirmed;
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
      success: (_) => ref.invalidate(branchVisitsProvider),
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
    final canPerform = ref.watch(hasPermissionProvider('checkin.perform'));
    final canOverride = ref.watch(hasPermissionProvider('checkin.override'));
    final visitsAsync = ref.watch(branchVisitsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RitmaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RitmaSectionHeader(
            title: 'Front-Desk Facility Check-In',
            subtitle: 'Validate rotating member QR tokens, enforce entitlements, and monitor occupancy',
          ),
          const SizedBox(height: RitmaSpacing.md),
          if (workspace.branchId == null && branches.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              initialValue: activeBranchId,
              decoration: const InputDecoration(
                labelText: 'Check-In Branch',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              items: branches
                  .map(
                    (b) => DropdownMenuItem<String>(
                      value: b.id,
                      child: Text(b.name),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedBranchId = val),
            ),
            const SizedBox(height: RitmaSpacing.md),
          ],
          if (_lastOutcome != null) ...[
            _OutcomeBanner(outcome: _lastOutcome!),
            const SizedBox(height: RitmaSpacing.md),
          ],
          if (canPerform && activeBranchId != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(RitmaSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'QR Pass Validation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: RitmaSpacing.xs),
                    TextField(
                      controller: _qrController,
                      decoration: const InputDecoration(
                        labelText: 'Member QR Token',
                        hintText: 'Paste or scan token payload...',
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
                      icon: const Icon(Icons.verified_outlined, size: 18),
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: RitmaSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _lookupController,
                            decoration: const InputDecoration(
                              labelText: 'Name or Member Code',
                              prefixIcon: Icon(Icons.person_search_outlined),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    if (_lookupResults.isNotEmpty) ...[
                      const SizedBox(height: RitmaSpacing.sm),
                      ..._lookupResults.map(
                        (member) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(member.fullName),
                          subtitle: Text(
                            '${member.memberCode} • ${member.status.toUpperCase()}',
                          ),
                          trailing: Wrap(
                            spacing: RitmaSpacing.xs,
                            children: [
                              OutlinedButton(
                                onPressed: _submitting
                                    ? null
                                    : () => _manualCheckIn(
                                        orgId: workspace.organizationId,
                                        branchId: activeBranchId,
                                        memberId: member.id,
                                      ),
                                child: const Text('Check In'),
                              ),
                              if (canOverride)
                                FilledButton.tonal(
                                  onPressed: _submitting
                                      ? null
                                      : () => _manualCheckIn(
                                          orgId: workspace.organizationId,
                                          branchId: activeBranchId,
                                          memberId: member.id,
                                          forceOverride: true,
                                        ),
                                  child: const Text('Override'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: RitmaSpacing.lg),
          ],
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
            emptyMessage: 'Validated check-ins appear here in real time.',
            onRetry: () => ref.invalidate(branchVisitsProvider),
            data: (visits) {
              final fmt = DateFormat.jm();
              return Column(
                children: visits
                    .map(
                      (visit) => Padding(
                        padding: const EdgeInsets.only(bottom: RitmaSpacing.xs),
                        child: Card(
                          child: ListTile(
                            leading: Icon(
                              visit.checkInMethod == 'qr'
                                  ? Icons.qr_code_2
                                  : Icons.badge_outlined,
                            ),
                            title: Text(
                              visit.memberName ??
                                  'Member ${visit.memberId.substring(0, 8)}',
                            ),
                            subtitle: Text(
                              'In ${fmt.format(visit.checkedInAt.toLocal())}'
                              '${visit.checkedOutAt != null ? ' • Out ${fmt.format(visit.checkedOutAt!.toLocal())}' : ' • Active inside'}'
                              '${visit.overrideReason != null ? '\nOverride: ${visit.overrideReason}' : ''}',
                            ),
                            trailing: visit.checkedOutAt == null && canPerform
                                ? OutlinedButton(
                                    onPressed: () => _checkOut(
                                      orgId: workspace.organizationId,
                                      visitId: visit.id,
                                    ),
                                    child: const Text('Check Out'),
                                  )
                                : RitmaStatusPill(
                                    label: visit.checkedOutAt == null
                                        ? 'IN FACILITY'
                                        : 'CHECKED OUT',
                                    tone: visit.checkedOutAt == null
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

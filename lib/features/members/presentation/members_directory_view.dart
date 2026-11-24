import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_page_container.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/branch_model.dart';
import '../../packages/presentation/assign_package_sheet.dart';
import '../../packages/presentation/member_entitlements_panel.dart';
import '../application/member_providers.dart';
import '../domain/member_model.dart';

class MembersDirectoryView extends ConsumerWidget {
  const MembersDirectoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final membersAsync = ref.watch(membersListProvider);
    final statusFilter = ref.watch(memberStatusFilterProvider);
    final canWriteMembers = ref.watch(hasPermissionProvider('member.write'));

    if (workspace == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        RitmaPageContainer(
          maxWidth: 1200,
          padding: const EdgeInsets.fromLTRB(
            RitmaSpacing.md,
            RitmaSpacing.md,
            RitmaSpacing.md,
            RitmaSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RitmaSectionHeader(
                title: 'Member Directory',
                subtitle:
                    'Branch-scoped member profiles, status, and entitlements',
                trailing: canWriteMembers
                    ? FilledButton.icon(
                        onPressed: () => _showRegisterMemberDialog(
                          context,
                          ref,
                          workspace.organizationId,
                          workspace.branchId,
                        ),
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('Register'),
                      )
                    : null,
              ),
              const SizedBox(height: RitmaSpacing.sm),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search by name or member code',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) => ref
                    .read(memberSearchQueryProvider.notifier)
                    .setQuery(value),
              ),
              const SizedBox(height: RitmaSpacing.xs),
              Wrap(
                spacing: RitmaSpacing.xs,
                runSpacing: RitmaSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: statusFilter == null,
                    onSelected: (_) => ref
                        .read(memberStatusFilterProvider.notifier)
                        .setStatus(null),
                  ),
                  ...[
                    MemberStatus.active,
                    MemberStatus.frozen,
                    MemberStatus.suspended,
                  ].map(
                    (st) => FilterChip(
                      label: Text(st.displayLabel),
                      selected: statusFilter == st,
                      onSelected: (_) => ref
                          .read(memberStatusFilterProvider.notifier)
                          .setStatus(statusFilter == st ? null : st),
                    ),
                  ),
                  if (membersAsync.asData?.value case final list?) ...[
                    RitmaStatusPill(
                      label: '${list.length} shown',
                      icon: Icons.groups_outlined,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: AsyncStateView<List<MemberModel>>(
            value: membersAsync,
            isEmpty: (list) => list.isEmpty,
            emptyTitle: 'No members found',
            emptyMessage: 'Register a member or clear search filters.',
            onRetry: () => ref.invalidate(membersListProvider),
            data: (members) => ListView.separated(
              padding: const EdgeInsets.only(bottom: RitmaSpacing.lg),
              itemCount: members.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: RitmaSpacing.xs),
              itemBuilder: (context, index) {
                final m = members[index];
                return RitmaPageContainer(
                  maxWidth: 1200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: RitmaSpacing.md,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          m.fullName.isNotEmpty
                              ? m.fullName[0].toUpperCase()
                              : 'M',
                        ),
                      ),
                      title: Text(m.fullName),
                      subtitle: Text(
                        '${m.memberCode}${m.email != null ? ' • ${m.email}' : ''}',
                      ),
                      trailing: RitmaStatusPill(
                        label: m.status.displayLabel,
                        tone: m.status == MemberStatus.active
                            ? RitmaPillTone.success
                            : m.status == MemberStatus.frozen
                            ? RitmaPillTone.warning
                            : RitmaPillTone.danger,
                      ),
                      onTap: () => _openMemberDetail(context, m),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _openMemberDetail(BuildContext context, MemberModel member) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: _MemberDetailSheet(member: member),
      ),
    );
  }

  Future<void> _showRegisterMemberDialog(
    BuildContext context,
    WidgetRef ref,
    String orgId,
    String? scopedBranchId,
  ) async {
    final branches = await ref.read(orgBranchesProvider.future);
    if (!context.mounted) {
      return;
    }
    final defaultBranchId = scopedBranchId ?? branches.firstOrNull?.id;
    if (defaultBranchId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Create a branch first.')));
      return;
    }

    final createdName = await showDialog<String>(
      context: context,
      builder: (_) => _RegisterMemberDialog(
        orgId: orgId,
        scopedBranchId: scopedBranchId,
        branches: branches,
        initialBranchId: defaultBranchId,
      ),
    );
    if (createdName != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Member "$createdName" registered.')),
      );
    }
  }
}

class _RegisterMemberDialog extends ConsumerStatefulWidget {
  const _RegisterMemberDialog({
    required this.orgId,
    required this.scopedBranchId,
    required this.branches,
    required this.initialBranchId,
  });

  final String orgId;
  final String? scopedBranchId;
  final List<BranchModel> branches;
  final String initialBranchId;

  @override
  ConsumerState<_RegisterMemberDialog> createState() =>
      _RegisterMemberDialogState();
}

class _RegisterMemberDialogState extends ConsumerState<_RegisterMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  late String _selectedBranchId = widget.initialBranchId;
  bool _saving = false;
  String? _inlineError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _inlineError = 'Please fix the highlighted fields.');
      return;
    }
    final repo = ref.read(memberRepositoryProvider);
    if (repo == null) {
      setState(() => _inlineError = 'Member service unavailable.');
      return;
    }
    setState(() {
      _saving = true;
      _inlineError = null;
    });
    final memberName = _nameCtrl.text.trim();
    final res = await repo.registerMember(
      orgId: widget.orgId,
      homeBranchId: _selectedBranchId,
      memberCode: _codeCtrl.text,
      fullName: memberName,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    res.when(
      success: (_) {
        ref.invalidate(membersListProvider);
        Navigator.of(context).pop(memberName);
      },
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Register Member'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_inlineError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(RitmaSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(RitmaRadius.md),
                      border: Border.all(color: theme.colorScheme.error),
                    ),
                    child: Text(
                      _inlineError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Enter at least 2 characters.'
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Member Code (e.g. RTM-2001)',
                  ),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Enter a member code (min 2 chars).'
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                if (widget.scopedBranchId == null &&
                    widget.branches.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBranchId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Home Branch'),
                    items: widget.branches
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(
                              b.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedBranchId = val);
                      }
                    },
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                  ),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone (optional)',
                  ),
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
          child: Text(_saving ? 'Registering...' : 'Register'),
        ),
      ],
    );
  }
}

class _MemberDetailSheet extends ConsumerWidget {
  const _MemberDetailSheet({required this.member});

  final MemberModel member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAssign = ref.watch(hasPermissionProvider('entitlement.assign'));
    final canWriteMember = ref.watch(hasPermissionProvider('member.write'));
    final canReadEntitlements = ref.watch(
      hasPermissionProvider('entitlement.read'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(member.fullName),
        actions: [
          if (canAssign)
            Padding(
              padding: const EdgeInsets.only(right: RitmaSpacing.sm),
              child: FilledButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AssignPackageSheet(
                    memberId: member.id,
                    memberName: member.fullName,
                    homeBranchId: member.homeBranchId,
                  ),
                ),
                icon: const Icon(Icons.add_card_outlined, size: 18),
                label: const Text('Assign Package'),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(RitmaSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: RitmaSpacing.xs,
              runSpacing: RitmaSpacing.xs,
              children: [
                RitmaStatusPill(
                  label: member.memberCode,
                  icon: Icons.badge_outlined,
                ),
                RitmaStatusPill(
                  label: member.status.displayLabel,
                  tone: member.status == MemberStatus.active
                      ? RitmaPillTone.success
                      : RitmaPillTone.warning,
                ),
              ],
            ),
            if (canWriteMember) ...[
              const SizedBox(height: RitmaSpacing.sm),
              Wrap(
                spacing: RitmaSpacing.xs,
                children: [
                  if (member.status != MemberStatus.frozen)
                    OutlinedButton(
                      onPressed: () async {
                        final repo = ref.read(memberRepositoryProvider);
                        if (repo == null) {
                          return;
                        }
                        await repo.setMemberStatus(
                          orgId: member.organizationId,
                          memberId: member.id,
                          status: MemberStatus.frozen,
                        );
                        ref.invalidate(membersListProvider);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Freeze Profile'),
                    ),
                  if (member.status != MemberStatus.active)
                    OutlinedButton(
                      onPressed: () async {
                        final repo = ref.read(memberRepositoryProvider);
                        if (repo == null) {
                          return;
                        }
                        await repo.setMemberStatus(
                          orgId: member.organizationId,
                          memberId: member.id,
                          status: MemberStatus.active,
                        );
                        ref.invalidate(membersListProvider);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Reactivate Profile'),
                    ),
                ],
              ),
            ],
            if (canReadEntitlements) ...[
              const SizedBox(height: RitmaSpacing.md),
              MemberEntitlementsPanel(memberId: member.id),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/ritma_sync.dart';
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
                subtitle: 'Branch-scoped member profiles, status, claim onboarding, and entitlements',
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
              const _MemberSearchField(),
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
                    MemberStatus.archived,
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
                        '${m.memberCode}${m.email != null ? ' • ${m.email}' : ''}${m.userId == null ? ' • Unclaimed' : ''}',
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
      success: (created) {
        RitmaSync.afterMemberMutation(ref, memberId: created.id);
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

  Future<void> _setStatus(
    BuildContext context,
    WidgetRef ref,
    MemberStatus status,
  ) async {
    final repo = ref.read(memberRepositoryProvider);
    if (repo == null) return;
    final res = await repo.setMemberStatus(
      orgId: member.organizationId,
      memberId: member.id,
      status: status,
    );
    if (!context.mounted) return;
    res.when(
      success: (_) {
        RitmaSync.afterMemberMutation(ref, memberId: member.id);
        Navigator.of(context).pop();
      },
      failure: (f) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  Future<void> _generateClaimToken(BuildContext context, WidgetRef ref) async {
    final emailCtrl = TextEditingController(text: member.email ?? '');
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Member Claim Token'),
        content: TextField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Member Login Email',
            hintText: 'member@example.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(emailCtrl.text.trim()),
            child: const Text('Issue Token'),
          ),
        ],
      ),
    );
    emailCtrl.dispose();
    if (email == null || email.isEmpty || !context.mounted) return;

    final repo = ref.read(memberRepositoryProvider);
    if (repo == null) return;
    final res = await repo.inviteMemberClaim(
      orgId: member.organizationId,
      memberId: member.id,
      email: email,
    );
    if (!context.mounted) return;
    res.when(
      success: (token) => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Member Claim Token Ready'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Share this single-use claim token with $email. It links to ${member.fullName} (${member.memberCode}) when pasted in the Workspace Picker:',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              const SizedBox(height: RitmaSpacing.sm),
              SelectableText(token),
            ],
          ),
          actions: [
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: token));
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Claim token copied.')),
                  );
                }
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Token'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
      failure: (f) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAssign = ref.watch(hasPermissionProvider('entitlement.assign'));
    final canWriteMember = ref.watch(hasPermissionProvider('member.write'));
    final canReadEntitlements = ref.watch(
      hasPermissionProvider('entitlement.read'),
    );
    final liveMember =
        ref
            .watch(membersListProvider)
            .asData
            ?.value
            .where((m) => m.id == member.id)
            .firstOrNull ??
        member;

    return Scaffold(
      appBar: AppBar(
        title: Text(liveMember.fullName),
        actions: [
          if (canAssign)
            Padding(
              padding: const EdgeInsets.only(right: RitmaSpacing.sm),
              child: FilledButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AssignPackageSheet(
                    memberId: liveMember.id,
                    memberName: liveMember.fullName,
                    homeBranchId: liveMember.homeBranchId,
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
                  label: liveMember.memberCode,
                  icon: Icons.badge_outlined,
                ),
                RitmaStatusPill(
                  label: liveMember.status.displayLabel,
                  tone: liveMember.status == MemberStatus.active
                      ? RitmaPillTone.success
                      : liveMember.status == MemberStatus.frozen
                      ? RitmaPillTone.warning
                      : RitmaPillTone.danger,
                ),
                RitmaStatusPill(
                  label: liveMember.userId != null
                      ? 'Account Linked'
                      : 'Unclaimed Profile',
                  tone: liveMember.userId != null
                      ? RitmaPillTone.success
                      : RitmaPillTone.neutral,
                ),
              ],
            ),
            const SizedBox(height: RitmaSpacing.xs),
            if ((liveMember.email ?? '').isNotEmpty ||
                (liveMember.phone ?? '').isNotEmpty ||
                (liveMember.emergencyContactName ?? '').isNotEmpty)
              Card(
                margin: const EdgeInsets.only(top: RitmaSpacing.xs),
                child: Padding(
                  padding: const EdgeInsets.all(RitmaSpacing.sm),
                  child: Text(
                    [
                      if ((liveMember.email ?? '').isNotEmpty)
                        'Email: ${liveMember.email}',
                      if ((liveMember.phone ?? '').isNotEmpty)
                        'Phone: ${liveMember.phone}',
                      if ((liveMember.emergencyContactName ?? '').isNotEmpty)
                        'Emergency: ${liveMember.emergencyContactName} (${liveMember.emergencyContactPhone ?? '-'})',
                    ].join('\n'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            if (canWriteMember) ...[
              const SizedBox(height: RitmaSpacing.sm),
              Wrap(
                spacing: RitmaSpacing.xs,
                runSpacing: RitmaSpacing.xs,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => _EditMemberDialog(member: liveMember),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Details'),
                  ),
                  if (liveMember.userId == null)
                    FilledButton.tonalIcon(
                      onPressed: () => _generateClaimToken(context, ref),
                      icon: const Icon(Icons.key_outlined, size: 16),
                      label: const Text('Generate Claim Token'),
                    ),
                  if (liveMember.status != MemberStatus.frozen)
                    OutlinedButton(
                      onPressed: () =>
                          _setStatus(context, ref, MemberStatus.frozen),
                      child: const Text('Freeze Profile'),
                    ),
                  if (liveMember.status != MemberStatus.active)
                    OutlinedButton(
                      onPressed: () =>
                          _setStatus(context, ref, MemberStatus.active),
                      child: const Text('Reactivate Profile'),
                    ),
                  if (liveMember.status != MemberStatus.suspended)
                    TextButton(
                      onPressed: () =>
                          _setStatus(context, ref, MemberStatus.suspended),
                      child: const Text('Suspend'),
                    ),
                  if (liveMember.status != MemberStatus.archived)
                    TextButton(
                      onPressed: () =>
                          _setStatus(context, ref, MemberStatus.archived),
                      child: const Text('Archive'),
                    ),
                ],
              ),
            ],
            if (canReadEntitlements) ...[
              const SizedBox(height: RitmaSpacing.md),
              MemberEntitlementsPanel(memberId: liveMember.id),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditMemberDialog extends ConsumerStatefulWidget {
  const _EditMemberDialog({required this.member});

  final MemberModel member;

  @override
  ConsumerState<_EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends ConsumerState<_EditMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emergNameCtrl;
  late final TextEditingController _emergPhoneCtrl;
  late String _branchId;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _nameCtrl = TextEditingController(text: m.fullName);
    _emailCtrl = TextEditingController(text: m.email ?? '');
    _phoneCtrl = TextEditingController(text: m.phone ?? '');
    _emergNameCtrl = TextEditingController(text: m.emergencyContactName ?? '');
    _emergPhoneCtrl = TextEditingController(
      text: m.emergencyContactPhone ?? '',
    );
    _branchId = m.homeBranchId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _emergNameCtrl.dispose();
    _emergPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final repo = ref.read(memberRepositoryProvider);
    if (repo == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final res = await repo.updateMember(
      orgId: widget.member.organizationId,
      memberId: widget.member.id,
      homeBranchId: _branchId,
      fullName: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      emergencyContactName: _emergNameCtrl.text,
      emergencyContactPhone: _emergPhoneCtrl.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    res.when(
      success: (_) {
        RitmaSync.afterMemberMutation(ref, memberId: widget.member.id);
        Navigator.of(context).pop();
      },
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branches =
        ref.watch(orgBranchesProvider).asData?.value ?? const <BranchModel>[];
    final workspace = ref.watch(activeWorkspaceProvider);
    return AlertDialog(
      title: const Text('Edit Member Details'),
      content: SizedBox(
        width: 420,
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
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) =>
                      (v == null || v.trim().length < 2) ? 'Min 2 chars' : null,
                ),
                const SizedBox(height: RitmaSpacing.xs),
                if (workspace?.branchId == null &&
                    branches.any((b) => b.id == _branchId)) ...[
                  DropdownButtonFormField<String>(
                    initialValue: _branchId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Home Branch'),
                    items: branches
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _branchId = v);
                    },
                  ),
                  const SizedBox(height: RitmaSpacing.xs),
                ],
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _emergNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact Name',
                  ),
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _emergPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact Phone',
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
          child: Text(_saving ? 'Saving...' : 'Save Changes'),
        ),
      ],
    );
  }
}

class _MemberSearchField extends ConsumerStatefulWidget {
  const _MemberSearchField();

  @override
  ConsumerState<_MemberSearchField> createState() => _MemberSearchFieldState();
}

class _MemberSearchFieldState extends ConsumerState<_MemberSearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(memberSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      ref.read(memberSearchQueryProvider.notifier).setQuery(value);
    });
  }

  void _applyImmediately(String value) {
    _debounce?.cancel();
    ref.read(memberSearchQueryProvider.notifier).setQuery(value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        return TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Search by name, member code, email, or phone',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      _applyImmediately('');
                    },
                  ),
          ),
          onChanged: _onChanged,
          onSubmitted: _applyImmediately,
        );
      },
    );
  }
}

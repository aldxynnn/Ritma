import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../organizations/application/organization_providers.dart';
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
        Padding(
          padding: const EdgeInsets.all(RitmaSpacing.md),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: statusFilter == null,
                      onSelected: (_) => ref
                          .read(memberStatusFilterProvider.notifier)
                          .setStatus(null),
                    ),
                    const SizedBox(width: RitmaSpacing.xs),
                    ...[
                      MemberStatus.active,
                      MemberStatus.frozen,
                      MemberStatus.suspended,
                    ].map(
                      (st) => Padding(
                        padding: const EdgeInsets.only(right: RitmaSpacing.xs),
                        child: FilterChip(
                          label: Text(st.displayLabel),
                          selected: statusFilter == st,
                          onSelected: (_) => ref
                              .read(memberStatusFilterProvider.notifier)
                              .setStatus(statusFilter == st ? null : st),
                        ),
                      ),
                    ),
                  ],
                ),
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
              padding: const EdgeInsets.fromLTRB(
                RitmaSpacing.md,
                0,
                RitmaSpacing.md,
                RitmaSpacing.lg,
              ),
              itemCount: members.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: RitmaSpacing.xs),
              itemBuilder: (context, index) {
                final m = members[index];
                return Card(
                  child: ListTile(
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

    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    var selectedBranchId = defaultBranchId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('Register Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Member Code (e.g. RTM-2001)',
                  ),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                if (scopedBranchId == null && branches.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: selectedBranchId,
                    decoration: const InputDecoration(labelText: 'Home Branch'),
                    items: branches
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setInnerState(() => selectedBranchId = val);
                      }
                    },
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                  ),
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final repo = ref.read(memberRepositoryProvider);
                if (repo == null ||
                    nameCtrl.text.trim().length < 2 ||
                    codeCtrl.text.trim().isEmpty) {
                  return;
                }
                final res = await repo.registerMember(
                  orgId: orgId,
                  homeBranchId: selectedBranchId,
                  memberCode: codeCtrl.text,
                  fullName: nameCtrl.text,
                  email: emailCtrl.text,
                  phone: phoneCtrl.text,
                );
                if (!dialogContext.mounted) {
                  return;
                }
                res.when(
                  success: (_) {
                    ref.invalidate(membersListProvider);
                    Navigator.of(dialogContext).pop();
                  },
                  failure: (f) =>
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(f.message))),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
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

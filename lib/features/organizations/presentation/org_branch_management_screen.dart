import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/ritma_role.dart';
import '../application/organization_providers.dart';
import '../domain/branch_model.dart';
import '../domain/room_model.dart';

class OrgBranchManagementScreen extends ConsumerWidget {
  const OrgBranchManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final branchesAsync = ref.watch(orgBranchesProvider);
    final roomsAsync = ref.watch(orgRoomsProvider);
    final canManageBranch = ref.watch(hasPermissionProvider('branch.manage'));
    final canInvite = ref.watch(hasPermissionProvider('role.assign'));

    if (workspace == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Branches, Rooms & Staff')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(RitmaSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RitmaSectionHeader(
                  title: 'Branches',
                  subtitle:
                      'Physical facilities within ${workspace.organizationName}',
                  trailing: canManageBranch
                      ? FilledButton.icon(
                          onPressed: () => _showCreateBranchDialog(
                            context,
                            ref,
                            workspace.organizationId,
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Branch'),
                        )
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                AsyncStateView<List<BranchModel>>(
                  value: branchesAsync,
                  isEmpty: (list) => list.isEmpty,
                  emptyTitle: 'No branches configured',
                  onRetry: () => ref.invalidate(orgBranchesProvider),
                  data: (branches) => Column(
                    children: branches
                        .map(
                          (b) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: RitmaSpacing.xs,
                            ),
                            child: Card(
                              child: ListTile(
                                title: Text(b.name),
                                subtitle: Text(
                                  'Code: ${b.code}${b.address != null ? ' • ${b.address}' : ''}',
                                ),
                                trailing: RitmaStatusPill(
                                  label: b.isActive ? 'Active' : 'Inactive',
                                  tone: b.isActive
                                      ? RitmaPillTone.success
                                      : RitmaPillTone.neutral,
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
                  title: 'Studios & Rooms',
                  subtitle: 'Bookable studio spaces and functional floor zones',
                  trailing: canManageBranch
                      ? OutlinedButton.icon(
                          onPressed: () {
                            final branches =
                                branchesAsync.asData?.value ?? const [];
                            if (branches.isEmpty) {
                              return;
                            }
                            _showCreateRoomDialog(
                              context,
                              ref,
                              workspace.organizationId,
                              branches,
                            );
                          },
                          icon: const Icon(
                            Icons.meeting_room_outlined,
                            size: 18,
                          ),
                          label: const Text('Add Room'),
                        )
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                AsyncStateView<List<RoomModel>>(
                  value: roomsAsync,
                  isEmpty: (list) => list.isEmpty,
                  emptyTitle: 'No rooms added yet',
                  emptyMessage: 'Add studios or training zones to schedule capacity-capped classes.',
                  onRetry: () => ref.invalidate(orgRoomsProvider),
                  data: (rooms) => Column(
                    children: rooms
                        .map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: RitmaSpacing.xs,
                            ),
                            child: Card(
                              child: ListTile(
                                title: Text(r.name),
                                subtitle: Text(
                                  'Type: ${r.roomType} • Default capacity: ${r.defaultCapacity}',
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (canInvite) ...[
                  const SizedBox(height: RitmaSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(RitmaSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const RitmaSectionHeader(
                            title: 'Invite Staff & Instructors',
                            subtitle: 'Consent-based invitations enforce branch scope and role hierarchy.',
                          ),
                          const SizedBox(height: RitmaSpacing.sm),
                          FilledButton.icon(
                            onPressed: () {
                              final branches =
                                  branchesAsync.asData?.value ?? const [];
                              _showInviteStaffDialog(
                                context,
                                ref,
                                workspace.organizationId,
                                workspace.branchId,
                                branches,
                              );
                            },
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: const Text('Generate Staff Invitation'),
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
      ),
    );
  }

  Future<void> _showCreateBranchDialog(
    BuildContext context,
    WidgetRef ref,
    String orgId,
  ) async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Branch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Branch Name'),
            ),
            const SizedBox(height: RitmaSpacing.sm),
            TextField(
              controller: codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Branch Code (e.g. BR2)',
              ),
            ),
            const SizedBox(height: RitmaSpacing.sm),
            TextField(
              controller: addrCtrl,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final repo = ref.read(organizationRepositoryProvider);
              if (repo == null) {
                return;
              }
              final res = await repo.createBranch(
                orgId: orgId,
                name: nameCtrl.text,
                code: codeCtrl.text,
                address: addrCtrl.text,
              );
              if (!dialogContext.mounted) {
                return;
              }
              res.when(
                success: (_) {
                  ref.invalidate(orgBranchesProvider);
                  Navigator.of(dialogContext).pop();
                },
                failure: (f) =>
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(f.message))),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateRoomDialog(
    BuildContext context,
    WidgetRef ref,
    String orgId,
    List<BranchModel> branches,
  ) async {
    final nameCtrl = TextEditingController();
    final capCtrl = TextEditingController(text: '12');
    var selectedBranchId = branches.first.id;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('New Studio / Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedBranchId,
                decoration: const InputDecoration(labelText: 'Branch'),
                items: branches
                    .map(
                      (b) => DropdownMenuItem(value: b.id, child: Text(b.name)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setInnerState(() => selectedBranchId = val);
                  }
                },
              ),
              const SizedBox(height: RitmaSpacing.sm),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Room Name'),
              ),
              const SizedBox(height: RitmaSpacing.sm),
              TextField(
                controller: capCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Default Capacity',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final repo = ref.read(organizationRepositoryProvider);
                final cap = int.tryParse(capCtrl.text.trim()) ?? 0;
                if (repo == null || cap <= 0) {
                  return;
                }
                final res = await repo.createRoom(
                  orgId: orgId,
                  branchId: selectedBranchId,
                  name: nameCtrl.text,
                  roomType: 'studio',
                  defaultCapacity: cap,
                );
                if (!dialogContext.mounted) {
                  return;
                }
                res.when(
                  success: (_) {
                    ref.invalidate(orgRoomsProvider);
                    Navigator.of(dialogContext).pop();
                  },
                  failure: (f) =>
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(f.message))),
                );
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showInviteStaffDialog(
    BuildContext context,
    WidgetRef ref,
    String orgId,
    String? scopedBranchId,
    List<BranchModel> branches,
  ) async {
    final emailCtrl = TextEditingController();
    var selectedRole = RitmaRole.receptionist;
    var selectedBranchId = scopedBranchId ?? branches.firstOrNull?.id;
    String? issuedToken;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text('Invite Staff'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Staff Email'),
              ),
              const SizedBox(height: RitmaSpacing.sm),
              DropdownButtonFormField<RitmaRole>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items:
                    const [
                          RitmaRole.orgAdmin,
                          RitmaRole.branchManager,
                          RitmaRole.receptionist,
                          RitmaRole.gymStaff,
                          RitmaRole.instructor,
                          RitmaRole.personalTrainer,
                        ]
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.displayName),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setInnerState(() => selectedRole = val);
                  }
                },
              ),
              if (selectedRole != RitmaRole.orgAdmin &&
                  branches.isNotEmpty) ...[
                const SizedBox(height: RitmaSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: selectedBranchId,
                  decoration: const InputDecoration(labelText: 'Branch'),
                  items: branches
                      .map(
                        (b) =>
                            DropdownMenuItem(value: b.id, child: Text(b.name)),
                      )
                      .toList(),
                  onChanged: scopedBranchId != null
                      ? null
                      : (val) => setInnerState(() => selectedBranchId = val),
                ),
              ],
              if (issuedToken != null) ...[
                const SizedBox(height: RitmaSpacing.md),
                SelectableText('Invite Token: $issuedToken'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                final repo = ref.read(organizationRepositoryProvider);
                if (repo == null) {
                  return;
                }
                final res = await repo.inviteStaff(
                  orgId: orgId,
                  email: emailCtrl.text,
                  roleCode: selectedRole.code,
                  branchId: selectedRole == RitmaRole.orgAdmin
                      ? null
                      : selectedBranchId,
                );
                if (!dialogContext.mounted) {
                  return;
                }
                res.when(
                  success: (inv) =>
                      setInnerState(() => issuedToken = inv.token),
                  failure: (f) =>
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(f.message))),
                );
              },
              child: const Text('Generate Invite'),
            ),
          ],
        ),
      ),
    );
  }
}

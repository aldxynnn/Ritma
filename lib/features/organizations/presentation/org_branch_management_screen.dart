import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/ritma_sync.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/ritma_role.dart';
import '../application/organization_providers.dart';
import '../domain/branch_model.dart';
import '../domain/room_model.dart';
import '../domain/staff_management_models.dart';

class OrgBranchManagementScreen extends ConsumerWidget {
  const OrgBranchManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider);
    final branchesAsync = ref.watch(orgBranchesProvider);
    final roomsAsync = ref.watch(orgRoomsProvider);
    final staffAsync = ref.watch(orgStaffProvider);
    final invitationsAsync = ref.watch(orgInvitationsProvider);
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
            constraints: const BoxConstraints(maxWidth: 880),
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
                                trailing: Wrap(
                                  spacing: RitmaSpacing.xs,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    RitmaStatusPill(
                                      label: b.isActive ? 'Active' : 'Inactive',
                                      tone: b.isActive
                                          ? RitmaPillTone.success
                                          : RitmaPillTone.neutral,
                                    ),
                                    if (canManageBranch)
                                      IconButton(
                                        tooltip: 'Edit branch',
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          final saved = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => _EditBranchDialog(
                                              orgId: workspace.organizationId,
                                              branch: b,
                                            ),
                                          );
                                          if (saved == true) {
                                            RitmaSync.afterOrgOrStaffMutation(
                                              ref,
                                            );
                                          }
                                        },
                                      ),
                                  ],
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
                                  'Type: ${r.roomType} • Default capacity: ${r.defaultCapacity}${r.isActive ? '' : ' • Inactive'}',
                                ),
                                trailing: canManageBranch
                                    ? IconButton(
                                        tooltip: 'Edit room',
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          final saved = await showDialog<bool>(
                                            context: context,
                                            builder: (_) => _EditRoomDialog(
                                              orgId: workspace.organizationId,
                                              room: r,
                                            ),
                                          );
                                          if (saved == true) {
                                            RitmaSync.afterOrgOrStaffMutation(
                                              ref,
                                            );
                                          }
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (canInvite) ...[
                  const SizedBox(height: RitmaSpacing.lg),
                  RitmaSectionHeader(
                    title: 'Active Staff & Roles',
                    subtitle: 'Role hierarchy enforced by PostgreSQL; higher ranks cannot be modified by lower ranks',
                    trailing: FilledButton.icon(
                      onPressed: () {
                        final branches =
                            branchesAsync.asData?.value ?? const [];
                        _showInviteStaffDialog(
                          context,
                          workspace.organizationId,
                          workspace.branchId,
                          branches,
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Generate Staff Invitation'),
                    ),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                  AsyncStateView<List<StaffAssignmentModel>>(
                    value: staffAsync,
                    isEmpty: (list) =>
                        list.where((s) => s.status == 'active').isEmpty,
                    emptyTitle: 'No active staff assignments',
                    onRetry: () => ref.invalidate(orgStaffProvider),
                    data: (staff) => Column(
                      children: staff.where((s) => s.status == 'active').map((
                        s,
                      ) {
                        final canAct =
                            workspace.roleRank >= 100 ||
                            workspace.roleRank > s.roleRank;
                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: RitmaSpacing.xs,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(RitmaSpacing.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.badge_outlined),
                                    const SizedBox(width: RitmaSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.fullName.isNotEmpty
                                                ? s.fullName
                                                : (s.email.isNotEmpty
                                                      ? s.email
                                                      : s.userId),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          Text(
                                            '${s.roleDisplayName} • ${s.branchName ?? 'All Branches'}'
                                            '${s.email.isNotEmpty ? ' • ${s.email}' : ''}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (canAct) ...[
                                  const SizedBox(height: RitmaSpacing.xs),
                                  Wrap(
                                    spacing: RitmaSpacing.xs,
                                    runSpacing: RitmaSpacing.xs,
                                    children: [
                                      if (s.roleCode != 'org_owner')
                                        OutlinedButton(
                                          onPressed: () => showDialog<void>(
                                            context: context,
                                            builder: (_) =>
                                                _AssignAdditionalRoleDialog(
                                                  orgId:
                                                      workspace.organizationId,
                                                  actorRank: workspace.roleRank,
                                                  scopedBranchId:
                                                      workspace.branchId,
                                                  targetUserId: s.userId,
                                                  targetLabel:
                                                      s.fullName.isNotEmpty
                                                      ? s.fullName
                                                      : s.email,
                                                  branches:
                                                      branchesAsync
                                                          .asData
                                                          ?.value ??
                                                      const [],
                                                ),
                                          ),
                                          child: const Text('Add Role'),
                                        ),
                                      TextButton(
                                        onPressed: () => _revokeRole(
                                          context,
                                          ref,
                                          orgId: workspace.organizationId,
                                          assignment: s,
                                        ),
                                        child: const Text('Revoke'),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: RitmaSpacing.md),
                  const RitmaSectionHeader(
                    title: 'Pending Staff Invitations',
                    subtitle: 'Unaccepted consent-based role invitations',
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                  AsyncStateView<List<OrganizationInvitationModel>>(
                    value: invitationsAsync,
                    isEmpty: (list) =>
                        list.where((i) => i.status == 'pending').isEmpty,
                    emptyTitle: 'No pending invitations',
                    emptyMessage: 'Generate a staff invitation above to invite team members.',
                    onRetry: () => ref.invalidate(orgInvitationsProvider),
                    data: (invites) => Column(
                      children: invites.where((i) => i.status == 'pending').map((
                        inv,
                      ) {
                        final canRevoke =
                            workspace.roleRank >= 100 ||
                            workspace.roleRank > inv.roleRank;
                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: RitmaSpacing.xs,
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.mail_outline),
                            title: Text(inv.invitedEmail),
                            subtitle: Text(
                              '${inv.roleDisplayName} • ${inv.branchName ?? 'All Branches'}',
                            ),
                            trailing: canRevoke
                                ? TextButton(
                                    onPressed: () => _revokeInvitation(
                                      context,
                                      ref,
                                      orgId: workspace.organizationId,
                                      invitationId: inv.id,
                                    ),
                                    child: const Text('Revoke'),
                                  )
                                : const RitmaStatusPill(label: 'Locked'),
                          ),
                        );
                      }).toList(),
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

  Future<void> _revokeRole(
    BuildContext context,
    WidgetRef ref, {
    required String orgId,
    required StaffAssignmentModel assignment,
  }) async {
    final repo = ref.read(organizationRepositoryProvider);
    if (repo == null) return;
    final res = await repo.revokeUserRole(
      orgId: orgId,
      assignmentId: assignment.assignmentId,
    );
    if (!context.mounted) return;
    res.when(
      success: (_) {
        RitmaSync.afterOrgOrStaffMutation(ref);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Staff role revoked.')));
      },
      failure: (f) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  Future<void> _revokeInvitation(
    BuildContext context,
    WidgetRef ref, {
    required String orgId,
    required String invitationId,
  }) async {
    final repo = ref.read(organizationRepositoryProvider);
    if (repo == null) return;
    final res = await repo.revokeOrganizationInvitation(
      orgId: orgId,
      invitationId: invitationId,
    );
    if (!context.mounted) return;
    res.when(
      success: (_) {
        RitmaSync.afterOrgOrStaffMutation(ref);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invitation revoked.')));
      },
      failure: (f) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  Future<void> _showCreateBranchDialog(
    BuildContext context,
    String orgId,
  ) async {
    final createdName = await showDialog<String>(
      context: context,
      builder: (_) => _CreateBranchDialog(orgId: orgId),
    );
    if (createdName != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Branch "$createdName" created.')));
    }
  }

  Future<void> _showCreateRoomDialog(
    BuildContext context,
    String orgId,
    List<BranchModel> branches,
  ) async {
    final createdName = await showDialog<String>(
      context: context,
      builder: (_) => _CreateRoomDialog(orgId: orgId, branches: branches),
    );
    if (createdName != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Room "$createdName" created.')));
    }
  }

  Future<void> _showInviteStaffDialog(
    BuildContext context,
    String orgId,
    String? scopedBranchId,
    List<BranchModel> branches,
  ) {
    return showDialog<void>(
      context: context,
      builder: (_) => _InviteStaffDialog(
        orgId: orgId,
        scopedBranchId: scopedBranchId,
        branches: branches,
      ),
    );
  }
}

class _CreateBranchDialog extends ConsumerStatefulWidget {
  const _CreateBranchDialog({required this.orgId});

  final String orgId;

  @override
  ConsumerState<_CreateBranchDialog> createState() =>
      _CreateBranchDialogState();
}

class _CreateBranchDialogState extends ConsumerState<_CreateBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  bool _saving = false;
  String? _inlineError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _inlineError = 'Fix the highlighted fields.');
      return;
    }
    final repo = ref.read(organizationRepositoryProvider);
    if (repo == null) {
      setState(() => _inlineError = 'Organization service unavailable.');
      return;
    }
    setState(() {
      _saving = true;
      _inlineError = null;
    });
    final branchName = _nameCtrl.text.trim();
    final res = await repo.createBranch(
      orgId: widget.orgId,
      name: branchName,
      code: _codeCtrl.text,
      address: _addrCtrl.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    res.when(
      success: (_) {
        ref.invalidate(orgBranchesProvider);
        Navigator.of(context).pop(branchName);
      },
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Branch'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_inlineError != null) ...[
                  Text(
                    _inlineError!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Branch Name'),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Enter at least 2 characters.'
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Branch Code (e.g. BR2)',
                  ),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Enter a branch code (min 2 chars).'
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _addrCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Address (optional)',
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
          child: Text(_saving ? 'Creating...' : 'Create'),
        ),
      ],
    );
  }
}

class _CreateRoomDialog extends ConsumerStatefulWidget {
  const _CreateRoomDialog({required this.orgId, required this.branches});

  final String orgId;
  final List<BranchModel> branches;

  @override
  ConsumerState<_CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends ConsumerState<_CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _capCtrl = TextEditingController(text: '12');
  late String _selectedBranchId = widget.branches.first.id;
  bool _saving = false;
  String? _inlineError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _inlineError = 'Fix the highlighted fields.');
      return;
    }
    final repo = ref.read(organizationRepositoryProvider);
    final cap = int.tryParse(_capCtrl.text.trim()) ?? 0;
    if (repo == null || cap <= 0) {
      setState(() => _inlineError = 'Enter valid room details.');
      return;
    }
    setState(() {
      _saving = true;
      _inlineError = null;
    });
    final roomName = _nameCtrl.text.trim();
    final res = await repo.createRoom(
      orgId: widget.orgId,
      branchId: _selectedBranchId,
      name: roomName,
      roomType: 'studio',
      defaultCapacity: cap,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    res.when(
      success: (_) {
        ref.invalidate(orgRoomsProvider);
        Navigator.of(context).pop(roomName);
      },
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Studio / Room'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_inlineError != null) ...[
                  Text(
                    _inlineError!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                DropdownButtonFormField<String>(
                  initialValue: _selectedBranchId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Branch'),
                  items: widget.branches
                      .map(
                        (b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name, overflow: TextOverflow.ellipsis),
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
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Room Name'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Room name is required.'
                      : null,
                ),
                const SizedBox(height: RitmaSpacing.sm),
                TextFormField(
                  controller: _capCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Default Capacity',
                  ),
                  validator: (v) {
                    final cap = int.tryParse((v ?? '').trim()) ?? 0;
                    return cap < 1 ? 'Min capacity 1.' : null;
                  },
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
          child: Text(_saving ? 'Creating...' : 'Create'),
        ),
      ],
    );
  }
}

class _InviteStaffDialog extends ConsumerStatefulWidget {
  const _InviteStaffDialog({
    required this.orgId,
    required this.scopedBranchId,
    required this.branches,
  });

  final String orgId;
  final String? scopedBranchId;
  final List<BranchModel> branches;

  @override
  ConsumerState<_InviteStaffDialog> createState() => _InviteStaffDialogState();
}

class _InviteStaffDialogState extends ConsumerState<_InviteStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  RitmaRole _selectedRole = RitmaRole.receptionist;
  late String? _selectedBranchId =
      widget.scopedBranchId ?? widget.branches.firstOrNull?.id;
  String? _issuedToken;
  String? _inlineError;
  bool _saving = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _inlineError = 'Enter a valid staff email.');
      return;
    }
    final repo = ref.read(organizationRepositoryProvider);
    if (repo == null) {
      setState(() => _inlineError = 'Organization service unavailable.');
      return;
    }
    setState(() {
      _saving = true;
      _inlineError = null;
    });
    final res = await repo.inviteStaff(
      orgId: widget.orgId,
      email: _emailCtrl.text,
      roleCode: _selectedRole.code,
      branchId: _selectedRole == RitmaRole.orgAdmin ? null : _selectedBranchId,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    res.when(
      success: (inv) {
        RitmaSync.afterOrgOrStaffMutation(ref);
        setState(() => _issuedToken = inv.token);
      },
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actorRank = ref.watch(activeWorkspaceProvider)?.roleRank ?? 0;
    final assignableRoles = const [
      RitmaRole.orgAdmin,
      RitmaRole.branchManager,
      RitmaRole.receptionist,
      RitmaRole.gymStaff,
      RitmaRole.instructor,
      RitmaRole.personalTrainer,
    ].where((r) => actorRank >= 100 || r.rank < actorRank).toList();
    if (!assignableRoles.contains(_selectedRole) &&
        assignableRoles.isNotEmpty) {
      _selectedRole = assignableRoles.first;
    }

    return AlertDialog(
      title: const Text('Invite Staff'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_inlineError != null) ...[
                  Text(
                    _inlineError!,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: RitmaSpacing.sm),
                ],
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Staff Email'),
                  validator: (v) {
                    final email = v?.trim() ?? '';
                    return email.isEmpty || !email.contains('@')
                        ? 'Enter a valid email.'
                        : null;
                  },
                ),
                const SizedBox(height: RitmaSpacing.sm),
                DropdownButtonFormField<RitmaRole>(
                  initialValue: _selectedRole,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: assignableRoles
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                            r.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedRole = val);
                    }
                  },
                ),
                if (_selectedRole != RitmaRole.orgAdmin &&
                    widget.branches.isNotEmpty) ...[
                  const SizedBox(height: RitmaSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedBranchId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Branch'),
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
                    onChanged: widget.scopedBranchId != null
                        ? null
                        : (val) => setState(() => _selectedBranchId = val),
                  ),
                ],
                if (_issuedToken != null) ...[
                  const SizedBox(height: RitmaSpacing.md),
                  SelectableText('Invite Token: $_issuedToken'),
                  const SizedBox(height: RitmaSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: _issuedToken!),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invite token copied.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Token'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: Text(_saving ? 'Generating...' : 'Generate Invite'),
        ),
      ],
    );
  }
}

class _EditBranchDialog extends ConsumerStatefulWidget {
  const _EditBranchDialog({required this.orgId, required this.branch});

  final String orgId;
  final BranchModel branch;

  @override
  ConsumerState<_EditBranchDialog> createState() => _EditBranchDialogState();
}

class _EditBranchDialogState extends ConsumerState<_EditBranchDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _addrCtrl;
  late bool _isActive;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.branch.name);
    _codeCtrl = TextEditingController(text: widget.branch.code);
    _addrCtrl = TextEditingController(text: widget.branch.address ?? '');
    _isActive = widget.branch.isActive;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _addrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Branch'),
      content: SizedBox(
        width: 400,
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
                  decoration: const InputDecoration(labelText: 'Branch Name'),
                  validator: (v) =>
                      (v == null || v.trim().length < 2) ? 'Min 2 chars' : null,
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(labelText: 'Branch Code'),
                  validator: (v) =>
                      (v == null || v.trim().length < 2) ? 'Min 2 chars' : null,
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _addrCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text('Branch Active'),
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
          onPressed: _saving
              ? null
              : () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final repo = ref.read(organizationRepositoryProvider);
                  if (repo == null) return;
                  setState(() {
                    _saving = true;
                    _error = null;
                  });
                  final res = await repo.updateBranch(
                    orgId: widget.orgId,
                    branchId: widget.branch.id,
                    name: _nameCtrl.text,
                    code: _codeCtrl.text,
                    address: _addrCtrl.text,
                    timezone: widget.branch.timezone,
                    isActive: _isActive,
                  );
                  if (!context.mounted) return;
                  setState(() => _saving = false);
                  res.when(
                    success: (_) => Navigator.of(context).pop(true),
                    failure: (f) => setState(() => _error = f.message),
                  );
                },
          child: Text(_saving ? 'Saving...' : 'Save Branch'),
        ),
      ],
    );
  }
}

class _EditRoomDialog extends ConsumerStatefulWidget {
  const _EditRoomDialog({required this.orgId, required this.room});

  final String orgId;
  final RoomModel room;

  @override
  ConsumerState<_EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends ConsumerState<_EditRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _typeCtrl;
  late final TextEditingController _capCtrl;
  late bool _isActive;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.room.name);
    _typeCtrl = TextEditingController(text: widget.room.roomType);
    _capCtrl = TextEditingController(text: '${widget.room.defaultCapacity}');
    _isActive = widget.room.isActive;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _capCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Room / Studio'),
      content: SizedBox(
        width: 400,
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
                  decoration: const InputDecoration(labelText: 'Room Name'),
                  validator: (v) =>
                      (v == null || v.trim().length < 2) ? 'Min 2 chars' : null,
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _typeCtrl,
                  decoration: const InputDecoration(labelText: 'Room Type'),
                ),
                const SizedBox(height: RitmaSpacing.xs),
                TextFormField(
                  controller: _capCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Default Capacity',
                  ),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    return (n == null || n < 1) ? 'Min 1' : null;
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text('Room Active'),
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
          onPressed: _saving
              ? null
              : () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final repo = ref.read(organizationRepositoryProvider);
                  if (repo == null) return;
                  final cap = int.tryParse(_capCtrl.text.trim()) ?? 1;
                  setState(() {
                    _saving = true;
                    _error = null;
                  });
                  final res = await repo.updateRoom(
                    orgId: widget.orgId,
                    roomId: widget.room.id,
                    name: _nameCtrl.text,
                    roomType: _typeCtrl.text,
                    defaultCapacity: cap,
                    isActive: _isActive,
                  );
                  if (!context.mounted) return;
                  setState(() => _saving = false);
                  res.when(
                    success: (_) => Navigator.of(context).pop(true),
                    failure: (f) => setState(() => _error = f.message),
                  );
                },
          child: Text(_saving ? 'Saving...' : 'Save Room'),
        ),
      ],
    );
  }
}

class _AssignAdditionalRoleDialog extends ConsumerStatefulWidget {
  const _AssignAdditionalRoleDialog({
    required this.orgId,
    required this.actorRank,
    required this.scopedBranchId,
    required this.targetUserId,
    required this.targetLabel,
    required this.branches,
  });

  final String orgId;
  final int actorRank;
  final String? scopedBranchId;
  final String targetUserId;
  final String targetLabel;
  final List<BranchModel> branches;

  @override
  ConsumerState<_AssignAdditionalRoleDialog> createState() =>
      _AssignAdditionalRoleDialogState();
}

class _AssignAdditionalRoleDialogState
    extends ConsumerState<_AssignAdditionalRoleDialog> {
  RitmaRole _role = RitmaRole.instructor;
  late String? _branchId =
      widget.scopedBranchId ?? widget.branches.firstOrNull?.id;
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final allowedRoles =
        const [
              RitmaRole.orgAdmin,
              RitmaRole.branchManager,
              RitmaRole.receptionist,
              RitmaRole.gymStaff,
              RitmaRole.instructor,
              RitmaRole.personalTrainer,
            ]
            .where((r) => widget.actorRank >= 100 || r.rank < widget.actorRank)
            .toList();
    if (!allowedRoles.contains(_role) && allowedRoles.isNotEmpty) {
      _role = allowedRoles.first;
    }

    return AlertDialog(
      title: Text('Assign Role to ${widget.targetLabel}'),
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
            DropdownButtonFormField<RitmaRole>(
              initialValue: _role,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Role'),
              items: allowedRoles
                  .map(
                    (r) =>
                        DropdownMenuItem(value: r, child: Text(r.displayName)),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _role = v);
              },
            ),
            if (_role != RitmaRole.orgAdmin && widget.branches.isNotEmpty) ...[
              const SizedBox(height: RitmaSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _branchId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Branch'),
                items: widget.branches
                    .map(
                      (b) => DropdownMenuItem(value: b.id, child: Text(b.name)),
                    )
                    .toList(),
                onChanged: widget.scopedBranchId != null
                    ? null
                    : (v) => setState(() => _branchId = v),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  final repo = ref.read(organizationRepositoryProvider);
                  if (repo == null) return;
                  setState(() {
                    _saving = true;
                    _error = null;
                  });
                  final res = await repo.assignUserRole(
                    orgId: widget.orgId,
                    targetUserId: widget.targetUserId,
                    roleCode: _role.code,
                    branchId: _role == RitmaRole.orgAdmin ? null : _branchId,
                  );
                  if (!context.mounted) return;
                  setState(() => _saving = false);
                  res.when(
                    success: (_) {
                      RitmaSync.afterOrgOrStaffMutation(ref);
                      Navigator.of(context).pop();
                    },
                    failure: (f) => setState(() => _error = f.message),
                  );
                },
          child: Text(_saving ? 'Assigning...' : 'Assign Role'),
        ),
      ],
    );
  }
}

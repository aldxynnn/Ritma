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
      success: (inv) => setState(() => _issuedToken = inv.token),
      failure: (f) => setState(() => _inlineError = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
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

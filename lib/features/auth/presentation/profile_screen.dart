import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/state/ritma_sync.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../members/application/member_providers.dart';
import '../../organizations/application/organization_providers.dart';
import '../../organizations/domain/organization_model.dart';
import '../../organizations/presentation/audit_logs_screen.dart';
import '../../payments/presentation/payments_ledger_view.dart';
import '../application/auth_providers.dart';
import '../domain/auth_session_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergNameCtrl = TextEditingController();
  final _emergPhoneCtrl = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  String? _statusMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergNameCtrl.dispose();
    _emergPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().length < 2) {
      setState(() => _statusMessage = 'Name must be at least 2 characters.');
      return;
    }
    setState(() {
      _saving = true;
      _statusMessage = null;
    });

    final result = await ref
        .read(authControllerProvider.notifier)
        .updateProfile(
          fullName: _nameController.text,
          phone: _phoneController.text,
        );

    final workspace = ref.read(activeWorkspaceProvider);
    final memberRepo = ref.read(memberRepositoryProvider);
    if (result.isSuccess && workspace?.memberId != null && memberRepo != null) {
      await memberRepo.updateMyMemberContact(
        orgId: workspace!.organizationId,
        phone: _phoneController.text,
        emergencyContactName: _emergNameCtrl.text,
        emergencyContactPhone: _emergPhoneCtrl.text,
      );
      RitmaSync.afterProfileMutation(ref);
    }

    if (!mounted) {
      return;
    }

    result.when(
      success: (_) {
        setState(() {
          _saving = false;
          _statusMessage = 'Profile updated.';
        });
      },
      failure: (failure) {
        setState(() {
          _saving = false;
          _statusMessage = failure.message;
        });
      },
    );
  }

  Future<void> _rotateQrKey(String orgId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rotate QR Signing Key?'),
        content: const Text(
          'Existing QR pass tokens expire on next verification and members automatically receive newly signed tokens.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Rotate Key'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repo = ref.read(organizationRepositoryProvider);
    if (repo == null) return;
    final res = await repo.rotateOrgSigningKey(orgId);
    if (!mounted) return;
    res.when(
      success: (_) {
        RitmaSync.afterOrgOrStaffMutation(ref);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization QR signing key rotated.')),
        );
      },
      failure: (f) =>
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final workspace = ref.watch(activeWorkspaceProvider);
    final org = ref.watch(activeOrganizationProvider).asData?.value;

    if (session is AuthenticatedSession && !_initialized) {
      _nameController.text = session.profile.fullName;
      _phoneController.text = session.profile.phone ?? '';
      _initialized = true;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(RitmaSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (workspace != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(RitmaSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const RitmaSectionHeader(title: 'Active Context'),
                        const SizedBox(height: RitmaSpacing.sm),
                        Text(
                          workspace.organizationName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: RitmaSpacing.xs),
                        Wrap(
                          spacing: RitmaSpacing.xs,
                          runSpacing: RitmaSpacing.xs,
                          children: [
                            RitmaStatusPill(
                              label: workspace.roleDisplayName,
                              tone: workspace.isOperationsSurface
                                  ? RitmaPillTone.lime
                                  : RitmaPillTone.success,
                            ),
                            RitmaStatusPill(
                              label: workspace.scopeLabel,
                              icon: Icons.location_on_outlined,
                            ),
                            if (org != null)
                              RitmaStatusPill(
                                label: '${org.currencyCode} • ${org.timezone}',
                                icon: Icons.public_outlined,
                              ),
                          ],
                        ),
                        const SizedBox(height: RitmaSpacing.md),
                        Wrap(
                          spacing: RitmaSpacing.sm,
                          runSpacing: RitmaSpacing.sm,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => context.go(AppRoutes.workspaces),
                              icon: const Icon(Icons.swap_horiz),
                              label: const Text('Switch Workspace or Role'),
                            ),
                            if (workspace.hasPermission('branch.manage') ||
                                workspace.hasPermission('role.assign'))
                              FilledButton.icon(
                                onPressed: () =>
                                    context.push(AppRoutes.opsOrgSetup),
                                icon: const Icon(
                                  Icons.business_outlined,
                                  size: 18,
                                ),
                                label: const Text('Branches, Rooms & Staff'),
                              ),
                            if (workspace.hasPermission('equipment.manage'))
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    context.push(AppRoutes.opsEquipment),
                                icon: const Icon(
                                  Icons.build_circle_outlined,
                                  size: 18,
                                ),
                                label: const Text('Equipment & Maintenance'),
                              ),
                            if (workspace.hasPermission('org.manage') &&
                                org != null)
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final saved = await showDialog<bool>(
                                    context: context,
                                    builder: (_) =>
                                        _OrgSettingsDialog(organization: org),
                                  );
                                  if (saved == true && context.mounted) {
                                    RitmaSync.afterOrgOrStaffMutation(ref);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Organization settings updated.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  size: 18,
                                ),
                                label: const Text('Org Settings'),
                              ),
                            if (workspace.hasPermission('org.manage'))
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _rotateQrKey(workspace.organizationId),
                                icon: const Icon(
                                  Icons.vpn_key_outlined,
                                  size: 18,
                                ),
                                label: const Text('Rotate QR Key'),
                              ),
                            if (workspace.hasPermission('audit.read'))
                              OutlinedButton.icon(
                                onPressed: () => showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) => const FractionallySizedBox(
                                    heightFactor: 0.85,
                                    child: AuditLogsSheet(),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.policy_outlined,
                                  size: 18,
                                ),
                                label: const Text('Audit Logs'),
                              ),
                            if (workspace.memberId != null)
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => const SizedBox(
                                      height: 520,
                                      child: PaymentsLedgerView(
                                        forMemberOnly: true,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 18,
                                ),
                                label: const Text('Payment History'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: RitmaSpacing.md),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(RitmaSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const RitmaSectionHeader(title: 'Identity & Contact'),
                      const SizedBox(height: RitmaSpacing.md),
                      if (session is AuthenticatedSession) ...[
                        Text(
                          session.user.email,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: RitmaSpacing.sm),
                      ],
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                        ),
                      ),
                      const SizedBox(height: RitmaSpacing.md),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      if (workspace?.memberId != null) ...[
                        const SizedBox(height: RitmaSpacing.md),
                        TextField(
                          controller: _emergNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Emergency Contact Name',
                          ),
                        ),
                        const SizedBox(height: RitmaSpacing.md),
                        TextField(
                          controller: _emergPhoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Emergency Contact Phone',
                          ),
                        ),
                      ],
                      if (_statusMessage != null) ...[
                        const SizedBox(height: RitmaSpacing.sm),
                        Text(
                          _statusMessage!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: RitmaSpacing.md),
                      FilledButton(
                        onPressed: _saving ? null : _saveProfile,
                        child: _saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Profile'),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const RitmaSectionHeader(
                        title: 'Appearance',
                        subtitle: 'Editorial Kinetic dark cockpit or daylight reception mode',
                      ),
                      const SizedBox(height: RitmaSpacing.sm),
                      SegmentedButton<ThemeMode>(
                        segments: const <ButtonSegment<ThemeMode>>[
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Dark'),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Light'),
                          ),
                        ],
                        selected: <ThemeMode>{
                          ref.watch(themeModeProvider) == ThemeMode.light
                              ? ThemeMode.light
                              : ThemeMode.dark,
                        },
                        onSelectionChanged: (values) => ref
                            .read(themeModeProvider.notifier)
                            .setMode(values.first),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: RitmaSpacing.lg),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrgSettingsDialog extends ConsumerStatefulWidget {
  const _OrgSettingsDialog({required this.organization});

  final OrganizationModel organization;

  @override
  ConsumerState<_OrgSettingsDialog> createState() => _OrgSettingsDialogState();
}

class _OrgSettingsDialogState extends ConsumerState<_OrgSettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late String _businessType;
  late String _timezone;
  late String _currencyCode;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.organization.name);
    _businessType = widget.organization.businessType;
    _timezone = widget.organization.timezone;
    _currencyCode = widget.organization.currencyCode;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Organization Settings'),
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
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().length < 2) ? 'Min 2 chars' : null,
                ),
                const SizedBox(height: RitmaSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue:
                      const {'gym', 'studio', 'hybrid'}.contains(_businessType)
                      ? _businessType
                      : 'hybrid',
                  decoration: const InputDecoration(labelText: 'Business Type'),
                  items: const [
                    DropdownMenuItem(value: 'gym', child: Text('Gym')),
                    DropdownMenuItem(value: 'studio', child: Text('Studio')),
                    DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _businessType = v);
                  },
                ),
                const SizedBox(height: RitmaSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue:
                      const {
                        'UTC',
                        'Asia/Jakarta',
                        'Asia/Singapore',
                        'Asia/Makassar',
                        'Asia/Jayapura',
                      }.contains(_timezone)
                      ? _timezone
                      : 'UTC',
                  decoration: const InputDecoration(labelText: 'Timezone'),
                  items: const [
                    DropdownMenuItem(value: 'UTC', child: Text('UTC')),
                    DropdownMenuItem(
                      value: 'Asia/Jakarta',
                      child: Text('Asia/Jakarta (WIB)'),
                    ),
                    DropdownMenuItem(
                      value: 'Asia/Makassar',
                      child: Text('Asia/Makassar (WITA)'),
                    ),
                    DropdownMenuItem(
                      value: 'Asia/Jayapura',
                      child: Text('Asia/Jayapura (WIT)'),
                    ),
                    DropdownMenuItem(
                      value: 'Asia/Singapore',
                      child: Text('Asia/Singapore'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _timezone = v);
                  },
                ),
                const SizedBox(height: RitmaSpacing.xs),
                DropdownButtonFormField<String>(
                  initialValue:
                      const {'USD', 'IDR', 'SGD', 'EUR'}.contains(_currencyCode)
                      ? _currencyCode
                      : 'USD',
                  decoration: const InputDecoration(labelText: 'Currency'),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                    DropdownMenuItem(value: 'IDR', child: Text('IDR (Rp)')),
                    DropdownMenuItem(value: 'SGD', child: Text('SGD (S\$)')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _currencyCode = v);
                  },
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
                  final res = await repo.updateOrganizationSettings(
                    orgId: widget.organization.id,
                    name: _nameCtrl.text,
                    businessType: _businessType,
                    timezone: _timezone,
                    currencyCode: _currencyCode,
                  );
                  if (!context.mounted) return;
                  setState(() => _saving = false);
                  res.when(
                    success: (_) => Navigator.of(context).pop(true),
                    failure: (f) => setState(() => _error = f.message),
                  );
                },
          child: Text(_saving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }
}

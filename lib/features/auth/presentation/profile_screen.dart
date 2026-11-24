import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
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
  bool _initialized = false;
  bool _saving = false;
  String? _statusMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).asData?.value;
    final workspace = ref.watch(activeWorkspaceProvider);

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ritma_spacing.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_session_state.dart';
import '../application/organization_providers.dart';

class CreateOrganizationSheet extends ConsumerStatefulWidget {
  const CreateOrganizationSheet({super.key});

  @override
  ConsumerState<CreateOrganizationSheet> createState() =>
      _CreateOrganizationSheetState();
}

class _CreateOrganizationSheetState
    extends ConsumerState<CreateOrganizationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _branchNameController = TextEditingController(text: 'Main Branch');
  final _branchCodeController = TextEditingController(text: 'MAIN');
  final _currencyController = TextEditingController(text: 'USD');
  String _businessType = 'hybrid';
  String _timezone = 'UTC';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _branchNameController.dispose();
    _branchCodeController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _syncSlug(String name) {
    final normalized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (normalized.isNotEmpty) {
      _slugController.text = normalized;
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final repo = ref.read(organizationRepositoryProvider);
    if (repo == null) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final result = await repo.createOrganizationWithOwner(
      name: _nameController.text,
      slug: _slugController.text,
      businessType: _businessType,
      timezone: _timezone,
      currencyCode: _currencyController.text,
      firstBranchName: _branchNameController.text,
      firstBranchCode: _branchCodeController.text,
    );

    if (!mounted) {
      return;
    }

    await result.when(
      success: (orgId) async {
        await ref.read(authControllerProvider.notifier).refreshWorkspaces();
        if (!mounted) {
          return;
        }
        final session = ref.read(authControllerProvider).asData?.value;
        if (session is AuthenticatedSession) {
          final created = session.workspaces
              .where(
                (w) => w.organizationId == orgId && w.roleCode == 'org_owner',
              )
              .firstOrNull;
          if (created != null) {
            ref.read(activeWorkspaceProvider.notifier).select(created);
          }
        }
        Navigator.of(context).pop(orgId);
      },
      failure: (failure) async {
        setState(() {
          _submitting = false;
          _error = failure.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: RitmaSpacing.lg,
        right: RitmaSpacing.lg,
        top: RitmaSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + RitmaSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Organization',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: RitmaSpacing.xs),
              Text(
                'Provision your fitness organization, founding owner role, and initial branch.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: RitmaSpacing.md),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: RitmaSpacing.sm),
              ],
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Organization Name',
                ),
                onChanged: _syncSlug,
                validator: (v) => (v?.trim().length ?? 0) < 2
                    ? 'Enter at least 2 characters.'
                    : null,
              ),
              const SizedBox(height: RitmaSpacing.sm),
              TextFormField(
                controller: _slugController,
                decoration: const InputDecoration(labelText: 'URL Slug'),
                validator: (v) {
                  final s = v?.trim() ?? '';
                  return RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(s)
                      ? null
                      : 'Use lowercase letters, numbers, and hyphens.';
                },
              ),
              const SizedBox(height: RitmaSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _businessType,
                decoration: const InputDecoration(labelText: 'Business Model'),
                items: const [
                  DropdownMenuItem(
                    value: 'hybrid',
                    child: Text('Hybrid (Gym + Studio)'),
                  ),
                  DropdownMenuItem(
                    value: 'traditional_gym',
                    child: Text('Traditional Gym'),
                  ),
                  DropdownMenuItem(
                    value: 'boutique_studio',
                    child: Text('Boutique Studio'),
                  ),
                  DropdownMenuItem(
                    value: 'crossfit_functional',
                    child: Text('CrossFit / Functional'),
                  ),
                  DropdownMenuItem(
                    value: 'multi_branch',
                    child: Text('Multi-Branch Organization'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _businessType = val);
                  }
                },
              ),
              const SizedBox(height: RitmaSpacing.sm),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _branchNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Branch Name',
                      ),
                      validator: (v) =>
                          (v?.trim().length ?? 0) < 2 ? 'Required.' : null,
                    ),
                  ),
                  const SizedBox(width: RitmaSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _branchCodeController,
                      decoration: const InputDecoration(labelText: 'Code'),
                      validator: (v) =>
                          (v?.trim().length ?? 0) < 2 ? 'Required.' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RitmaSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _timezone,
                      decoration: const InputDecoration(labelText: 'Timezone'),
                      items: const [
                        DropdownMenuItem(value: 'UTC', child: Text('UTC')),
                        DropdownMenuItem(
                          value: 'Asia/Jakarta',
                          child: Text('Asia/Jakarta'),
                        ),
                        DropdownMenuItem(
                          value: 'Asia/Singapore',
                          child: Text('Asia/Singapore'),
                        ),
                        DropdownMenuItem(
                          value: 'America/New_York',
                          child: Text('America/New_York'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _timezone = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: RitmaSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _currencyController,
                      decoration: const InputDecoration(labelText: 'Currency'),
                      validator: (v) =>
                          (v?.trim().length ?? 0) != 3 ? '3-letter code' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RitmaSpacing.md),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Organization'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

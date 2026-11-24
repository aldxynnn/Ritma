import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/ritma_spacing.dart';
import '../../../core/widgets/async_state_view.dart';
import '../../../core/widgets/ritma_section_header.dart';
import '../../../core/widgets/ritma_status_pill.dart';
import '../../../core/widgets/ritma_surface_badge.dart';
import '../../organizations/presentation/create_organization_sheet.dart';
import '../application/auth_providers.dart';
import '../domain/auth_session_state.dart';
import '../domain/workspace_context.dart';

class WorkspacePickerScreen extends ConsumerStatefulWidget {
  const WorkspacePickerScreen({super.key});

  @override
  ConsumerState<WorkspacePickerScreen> createState() =>
      _WorkspacePickerScreenState();
}

class _WorkspacePickerScreenState extends ConsumerState<WorkspacePickerScreen> {
  final _tokenController = TextEditingController();
  bool _submittingToken = false;
  String? _tokenFeedback;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _selectWorkspace(WorkspaceContext workspace) {
    ref.read(activeWorkspaceProvider.notifier).select(workspace);
    context.go(AppRoutes.defaultRouteForWorkspace(workspace));
  }

  Future<void> _redeemToken({required bool isStaffInvite}) async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      setState(() => _tokenFeedback = 'Enter a valid invitation token.');
      return;
    }

    setState(() {
      _submittingToken = true;
      _tokenFeedback = null;
    });

    final notifier = ref.read(authControllerProvider.notifier);
    final result = isStaffInvite
        ? await notifier.acceptInvitation(token)
        : await notifier.claimMemberProfile(token);

    if (!mounted) {
      return;
    }

    result.when(
      success: (_) {
        _tokenController.clear();
        setState(() {
          _submittingToken = false;
          _tokenFeedback = 'Access activated!';
        });
      },
      failure: (failure) {
        setState(() {
          _submittingToken = false;
          _tokenFeedback = failure.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final activeWorkspace = ref.watch(activeWorkspaceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Workspace'),
        actions: [
          IconButton(
            tooltip: 'Refresh Workspaces',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).refreshWorkspaces(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          const RitmaSurfaceBadge(),
          Expanded(
            child: AsyncStateView<AuthSessionState>(
              value: authAsync,
              onRetry: () => ref.invalidate(authControllerProvider),
              data: (session) {
                if (session is! AuthenticatedSession) {
                  return const SizedBox.shrink();
                }

                final opsContexts = session.workspaces
                    .where((w) => w.isOperationsSurface)
                    .toList();
                final memberContexts = session.workspaces
                    .where((w) => !w.isOperationsSurface)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(RitmaSpacing.lg),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: RitmaSpacing.sm,
                            runSpacing: RitmaSpacing.xs,
                            children: [
                              Text(
                                'Signed in as ${session.profile.fullName.isNotEmpty ? session.profile.fullName : session.user.email}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              FilledButton.icon(
                                onPressed: () => showModalBottomSheet<String>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (_) =>
                                      const CreateOrganizationSheet(),
                                ),
                                icon: const Icon(
                                  Icons.add_business_outlined,
                                  size: 18,
                                ),
                                label: const Text('Create Organization'),
                              ),
                            ],
                          ),
                          const SizedBox(height: RitmaSpacing.lg),
                          if (session.workspaces.isEmpty) ...[
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(RitmaSpacing.lg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const RitmaStatusPill(
                                      label: 'No Active Organization Yet',
                                      icon: Icons.domain_add_outlined,
                                      tone: RitmaPillTone.neutral,
                                    ),
                                    const SizedBox(height: RitmaSpacing.sm),
                                    Text(
                                      'Create a Fitness Business or Join via Token',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: RitmaSpacing.xs),
                                    Text(
                                      'Create a new gym or studio organization above, or accept a staff invitation / member pass claim token below.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: RitmaSpacing.lg),
                          ],
                          if (opsContexts.isNotEmpty) ...[
                            const RitmaSectionHeader(
                              title: 'Operations Workspaces',
                              subtitle: 'Staff, instructor, manager, and owner consoles',
                            ),
                            const SizedBox(height: RitmaSpacing.sm),
                            ...opsContexts.map(
                              (ws) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: RitmaSpacing.sm,
                                ),
                                child: _WorkspaceCard(
                                  workspace: ws,
                                  isSelected:
                                      activeWorkspace?.contextKey ==
                                      ws.contextKey,
                                  onTap: () => _selectWorkspace(ws),
                                ),
                              ),
                            ),
                            const SizedBox(height: RitmaSpacing.md),
                          ],
                          if (memberContexts.isNotEmpty) ...[
                            const RitmaSectionHeader(
                              title: 'Member Passes',
                              subtitle: 'Personal gym memberships, QR check-in, and class bookings',
                            ),
                            const SizedBox(height: RitmaSpacing.sm),
                            ...memberContexts.map(
                              (ws) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: RitmaSpacing.sm,
                                ),
                                child: _WorkspaceCard(
                                  workspace: ws,
                                  isSelected:
                                      activeWorkspace?.contextKey ==
                                      ws.contextKey,
                                  onTap: () => _selectWorkspace(ws),
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
                                  const RitmaSectionHeader(
                                    title: 'Redeem Invite or Claim Token',
                                    subtitle: 'Join an organization as staff or link an existing member profile',
                                  ),
                                  const SizedBox(height: RitmaSpacing.sm),
                                  TextField(
                                    controller: _tokenController,
                                    decoration: const InputDecoration(
                                      labelText: 'Invitation or Claim Token',
                                      prefixIcon: Icon(Icons.key_outlined),
                                    ),
                                  ),
                                  if (_tokenFeedback != null) ...[
                                    const SizedBox(height: RitmaSpacing.xs),
                                    Text(
                                      _tokenFeedback!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                  const SizedBox(height: RitmaSpacing.sm),
                                  Wrap(
                                    spacing: RitmaSpacing.sm,
                                    runSpacing: RitmaSpacing.sm,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: _submittingToken
                                            ? null
                                            : () => _redeemToken(
                                                isStaffInvite: true,
                                              ),
                                        icon: const Icon(
                                          Icons.work_outline,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          'Accept Staff Invite',
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: _submittingToken
                                            ? null
                                            : () => _redeemToken(
                                                isStaffInvite: false,
                                              ),
                                        icon: const Icon(
                                          Icons.qr_code_2_outlined,
                                          size: 18,
                                        ),
                                        label: const Text('Claim Member Pass'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.workspace,
    required this.isSelected,
    required this.onTap,
  });

  final WorkspaceContext workspace;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOps = workspace.isOperationsSurface;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RitmaRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(RitmaSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isOps
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.secondaryContainer,
                child: Icon(
                  isOps
                      ? Icons.admin_panel_settings_outlined
                      : Icons.badge_outlined,
                  color: isOps
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: RitmaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspace.organizationName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: RitmaSpacing.xxs),
                    Wrap(
                      spacing: RitmaSpacing.xs,
                      runSpacing: RitmaSpacing.xxs,
                      children: [
                        RitmaStatusPill(
                          label: workspace.roleDisplayName,
                          tone: isOps
                              ? RitmaPillTone.lime
                              : RitmaPillTone.success,
                        ),
                        RitmaStatusPill(
                          label: workspace.scopeLabel,
                          icon: Icons.location_on_outlined,
                          tone: RitmaPillTone.neutral,
                        ),
                        if (isSelected)
                          const RitmaStatusPill(
                            label: 'Active',
                            icon: Icons.check_circle_outline,
                            tone: RitmaPillTone.success,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

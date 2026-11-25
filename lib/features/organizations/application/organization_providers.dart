import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/audit_log_model.dart';
import '../domain/branch_model.dart';
import '../domain/organization_model.dart';
import '../domain/organization_repository.dart';
import '../domain/room_model.dart';
import '../domain/staff_management_models.dart';
import '../infrastructure/demo_sandbox_organization_repository.dart';
import '../infrastructure/supabase_organization_repository.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository?>((ref) {
  final mode = ref.watch(appModeProvider);
  switch (mode) {
    case AppMode.supabase:
      final client = ref.watch(supabaseClientProvider);
      return client != null ? SupabaseOrganizationRepository(client) : null;
    case AppMode.demoSandbox:
      return DemoSandboxOrganizationRepository(
        ref.watch(demoSandboxEngineProvider),
      );
    case AppMode.unconfigured:
      return null;
  }
});

final orgBranchesProvider = FutureProvider.autoDispose<List<BranchModel>>((
  ref,
) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  final repo = ref.watch(organizationRepositoryProvider);
  if (workspace == null || repo == null) {
    return const <BranchModel>[];
  }
  final result = await repo.fetchBranches(workspace.organizationId);
  return result.when(
    success: (list) => list,
    failure: (failure) => throw AppException(failure),
  );
});

final orgRoomsProvider = FutureProvider.autoDispose<List<RoomModel>>((
  ref,
) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  final repo = ref.watch(organizationRepositoryProvider);
  if (workspace == null || repo == null) {
    return const <RoomModel>[];
  }
  final result = await repo.fetchRooms(
    workspace.organizationId,
    branchId: workspace.branchId,
  );
  return result.when(
    success: (list) => list,
    failure: (failure) => throw AppException(failure),
  );
});

final activeOrganizationProvider =
    FutureProvider.autoDispose<OrganizationModel?>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(organizationRepositoryProvider);
      if (workspace == null || repo == null) {
        return null;
      }
      final result = await repo.fetchOrganization(workspace.organizationId);
      return result.when(
        success: (org) => org,
        failure: (failure) => throw AppException(failure),
      );
    });

final orgStaffProvider = FutureProvider.autoDispose<List<StaffAssignmentModel>>(
  (ref) async {
    final workspace = ref.watch(activeWorkspaceProvider);
    final repo = ref.watch(organizationRepositoryProvider);
    if (workspace == null ||
        repo == null ||
        !workspace.hasPermission('role.assign')) {
      return const <StaffAssignmentModel>[];
    }
    final result = await repo.fetchOrganizationStaff(
      orgId: workspace.organizationId,
      branchId: workspace.branchId,
    );
    return result.when(
      success: (list) => list,
      failure: (failure) => throw AppException(failure),
    );
  },
);

final orgInvitationsProvider =
    FutureProvider.autoDispose<List<OrganizationInvitationModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(organizationRepositoryProvider);
      if (workspace == null ||
          repo == null ||
          !workspace.hasPermission('role.assign')) {
        return const <OrganizationInvitationModel>[];
      }
      final result = await repo.fetchOrganizationInvitations(
        orgId: workspace.organizationId,
        branchId: workspace.branchId,
      );
      return result.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final auditLogsProvider = FutureProvider.autoDispose<List<AuditLogModel>>((
  ref,
) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  final repo = ref.watch(organizationRepositoryProvider);
  if (workspace == null ||
      repo == null ||
      !workspace.hasPermission('audit.read')) {
    return const <AuditLogModel>[];
  }
  final result = await repo.fetchAuditLogs(
    orgId: workspace.organizationId,
    branchId: workspace.branchId,
  );
  return result.when(
    success: (list) => list,
    failure: (failure) => throw AppException(failure),
  );
});

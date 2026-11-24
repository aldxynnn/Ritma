import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/facility_access_models.dart';
import '../domain/facility_access_repository.dart';
import '../infrastructure/demo_sandbox_facility_access_repository.dart';
import '../infrastructure/supabase_facility_access_repository.dart';

final facilityAccessRepositoryProvider = Provider<FacilityAccessRepository?>((
  ref,
) {
  final mode = ref.watch(appModeProvider);
  switch (mode) {
    case AppMode.supabase:
      final client = ref.watch(supabaseClientProvider);
      return client != null ? SupabaseFacilityAccessRepository(client) : null;
    case AppMode.demoSandbox:
      return DemoSandboxFacilityAccessRepository(
        ref.watch(demoSandboxEngineProvider),
      );
    case AppMode.unconfigured:
      return null;
  }
});

final memberQrPassProvider = FutureProvider.autoDispose<QrPassToken?>((
  ref,
) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  final repo = ref.watch(facilityAccessRepositoryProvider);
  final memberId = workspace?.memberId;
  if (workspace == null || repo == null || memberId == null) {
    return null;
  }
  final res = await repo.issueMemberQrToken(
    orgId: workspace.organizationId,
    memberId: memberId,
  );
  return res.when(
    success: (token) => token,
    failure: (failure) => throw AppException(failure),
  );
});

final branchVisitsProvider =
    FutureProvider.autoDispose<List<FacilityVisitModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(facilityAccessRepositoryProvider);
      if (workspace == null || repo == null) {
        return const <FacilityVisitModel>[];
      }
      final res = await repo.fetchBranchVisits(
        orgId: workspace.organizationId,
        branchId: workspace.branchId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final memberVisitsProvider =
    FutureProvider.autoDispose<List<FacilityVisitModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(facilityAccessRepositoryProvider);
      final memberId = workspace?.memberId;
      if (workspace == null || repo == null || memberId == null) {
        return const <FacilityVisitModel>[];
      }
      final res = await repo.fetchMemberVisits(
        orgId: workspace.organizationId,
        memberId: memberId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

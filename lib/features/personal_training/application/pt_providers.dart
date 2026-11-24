import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/pt_models.dart';
import '../domain/pt_repository.dart';
import '../infrastructure/demo_sandbox_pt_repository.dart';
import '../infrastructure/supabase_pt_repository.dart';

final ptRepositoryProvider = Provider<PtRepository?>((ref) {
  final mode = ref.watch(appModeProvider);
  switch (mode) {
    case AppMode.supabase:
      final client = ref.watch(supabaseClientProvider);
      return client != null ? SupabasePtRepository(client) : null;
    case AppMode.demoSandbox:
      return DemoSandboxPtRepository(ref.watch(demoSandboxEngineProvider));
    case AppMode.unconfigured:
      return null;
  }
});

final orgTrainersProvider =
    FutureProvider.autoDispose<List<TrainerProfileModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(ptRepositoryProvider);
      if (workspace == null || repo == null) {
        return const <TrainerProfileModel>[];
      }
      final res = await repo.fetchTrainers(
        orgId: workspace.organizationId,
        branchId: workspace.isOperationsSurface ? workspace.branchId : null,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final ptSessionsProvider = FutureProvider.autoDispose<List<PtSessionModel>>((
  ref,
) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  final repo = ref.watch(ptRepositoryProvider);
  if (workspace == null || repo == null) {
    return const <PtSessionModel>[];
  }
  final res = await repo.fetchPtSessions(
    orgId: workspace.organizationId,
    branchId: workspace.isOperationsSurface ? workspace.branchId : null,
    memberId: workspace.isOperationsSurface ? null : workspace.memberId,
  );
  return res.when(
    success: (list) => list,
    failure: (failure) => throw AppException(failure),
  );
});

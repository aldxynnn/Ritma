import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/dashboard_repository.dart';
import '../domain/operational_metrics_model.dart';
import '../infrastructure/demo_sandbox_dashboard_repository.dart';
import '../infrastructure/supabase_dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository?>((ref) {
  final mode = ref.watch(appModeProvider);
  switch (mode) {
    case AppMode.supabase:
      final client = ref.watch(supabaseClientProvider);
      return client != null ? SupabaseDashboardRepository(client) : null;
    case AppMode.demoSandbox:
      return DemoSandboxDashboardRepository(
        ref.watch(demoSandboxEngineProvider),
      );
    case AppMode.unconfigured:
      return null;
  }
});

class DashboardWindowDaysNotifier extends Notifier<int> {
  @override
  int build() => 30;

  void setWindow(int days) => state = days;
}

final dashboardWindowDaysProvider =
    NotifierProvider<DashboardWindowDaysNotifier, int>(
      DashboardWindowDaysNotifier.new,
    );

final operationalMetricsProvider =
    FutureProvider.autoDispose<OperationalMetricsModel>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(dashboardRepositoryProvider);
      final windowDays = ref.watch(dashboardWindowDaysProvider);
      if (workspace == null || repo == null) {
        return const OperationalMetricsModel();
      }
      final res = await repo.fetchOperationalMetrics(
        orgId: workspace.organizationId,
        branchId: workspace.branchId,
        windowDays: windowDays,
      );
      return res.when(
        success: (metrics) => metrics,
        failure: (failure) => throw AppException(failure),
      );
    });

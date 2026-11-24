import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../../auth/domain/auth_session_state.dart';
import '../domain/operations_extras_models.dart';
import '../domain/operations_extras_repository.dart';
import '../infrastructure/demo_sandbox_operations_extras_repository.dart';
import '../infrastructure/supabase_operations_extras_repository.dart';

final operationsExtrasRepositoryProvider =
    Provider<OperationsExtrasRepository?>((ref) {
      final mode = ref.watch(appModeProvider);
      switch (mode) {
        case AppMode.supabase:
          final client = ref.watch(supabaseClientProvider);
          return client != null
              ? SupabaseOperationsExtrasRepository(client)
              : null;
        case AppMode.demoSandbox:
          return DemoSandboxOperationsExtrasRepository(
            ref.watch(demoSandboxEngineProvider),
          );
        case AppMode.unconfigured:
          return null;
      }
    });

final equipmentAssetsProvider =
    FutureProvider.autoDispose<List<EquipmentAssetModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(operationsExtrasRepositoryProvider);
      if (workspace == null || repo == null) {
        return const <EquipmentAssetModel>[];
      }
      final res = await repo.fetchEquipmentAssets(
        orgId: workspace.organizationId,
        branchId: workspace.branchId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final maintenanceTicketsProvider =
    FutureProvider.autoDispose<List<MaintenanceTicketModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(operationsExtrasRepositoryProvider);
      if (workspace == null || repo == null) {
        return const <MaintenanceTicketModel>[];
      }
      final res = await repo.fetchMaintenanceTickets(
        orgId: workspace.organizationId,
        branchId: workspace.branchId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final userNotificationsProvider =
    FutureProvider.autoDispose<List<UserNotificationModel>>((ref) async {
      final authSession = ref.watch(authControllerProvider).asData?.value;
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(operationsExtrasRepositoryProvider);
      if (authSession is! AuthenticatedSession ||
          workspace == null ||
          repo == null) {
        return const <UserNotificationModel>[];
      }
      final res = await repo.fetchNotifications(
        orgId: workspace.organizationId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final notifications =
      ref.watch(userNotificationsProvider).asData?.value ??
      const <UserNotificationModel>[];
  return notifications.where((n) => n.readAt == null).length;
});

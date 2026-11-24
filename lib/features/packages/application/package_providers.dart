import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/package_entitlement_repository.dart';
import '../domain/package_models.dart';
import '../infrastructure/demo_sandbox_package_entitlement_repository.dart';
import '../infrastructure/supabase_package_entitlement_repository.dart';

final packageEntitlementRepositoryProvider =
    Provider<PackageEntitlementRepository?>((ref) {
      final mode = ref.watch(appModeProvider);
      switch (mode) {
        case AppMode.supabase:
          final client = ref.watch(supabaseClientProvider);
          return client != null
              ? SupabasePackageEntitlementRepository(client)
              : null;
        case AppMode.demoSandbox:
          return DemoSandboxPackageEntitlementRepository(
            ref.watch(demoSandboxEngineProvider),
          );
        case AppMode.unconfigured:
          return null;
      }
    });

final orgClassTypesProvider = FutureProvider.autoDispose<List<ClassTypeModel>>((
  ref,
) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  final repo = ref.watch(packageEntitlementRepositoryProvider);
  if (workspace == null || repo == null) {
    return const <ClassTypeModel>[];
  }
  final res = await repo.fetchClassTypes(workspace.organizationId);
  return res.when(
    success: (list) => list,
    failure: (failure) => throw AppException(failure),
  );
});

final orgPackagesProvider = FutureProvider.autoDispose<List<PackageModel>>((
  ref,
) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  final repo = ref.watch(packageEntitlementRepositoryProvider);
  if (workspace == null || repo == null) {
    return const <PackageModel>[];
  }
  final res = await repo.fetchPackages(workspace.organizationId);
  return res.when(
    success: (list) => list,
    failure: (failure) => throw AppException(failure),
  );
});

final memberWalletProvider = FutureProvider.autoDispose
    .family<MemberWalletSnapshot, String>((ref, memberId) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(packageEntitlementRepositoryProvider);
      if (workspace == null || repo == null) {
        return const MemberWalletSnapshot(
          subscriptions: <MemberSubscriptionModel>[],
          entitlements: <MemberEntitlementModel>[],
          creditGrants: <CreditGrantModel>[],
          ledgerEntries: <CreditLedgerEntryModel>[],
        );
      }
      final res = await repo.fetchMemberWallet(
        orgId: workspace.organizationId,
        memberId: memberId,
      );
      return res.when(
        success: (wallet) => wallet,
        failure: (failure) => throw AppException(failure),
      );
    });

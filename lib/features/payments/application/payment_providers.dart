import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/payment_record_model.dart';
import '../domain/payment_repository.dart';
import '../infrastructure/demo_sandbox_payment_repository.dart';
import '../infrastructure/supabase_payment_repository.dart';

final paymentRepositoryProvider = Provider<PaymentRepository?>((ref) {
  final mode = ref.watch(appModeProvider);
  switch (mode) {
    case AppMode.supabase:
      final client = ref.watch(supabaseClientProvider);
      return client != null ? SupabasePaymentRepository(client) : null;
    case AppMode.demoSandbox:
      return DemoSandboxPaymentRepository(ref.watch(demoSandboxEngineProvider));
    case AppMode.unconfigured:
      return null;
  }
});

final orgPaymentsProvider =
    FutureProvider.autoDispose<List<PaymentRecordModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(paymentRepositoryProvider);
      if (workspace == null || repo == null) {
        return const <PaymentRecordModel>[];
      }
      final res = await repo.fetchOrgPayments(
        orgId: workspace.organizationId,
        branchId: workspace.branchId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final memberPaymentsProvider =
    FutureProvider.autoDispose<List<PaymentRecordModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(paymentRepositoryProvider);
      final memberId = workspace?.memberId;
      if (workspace == null || repo == null || memberId == null) {
        return const <PaymentRecordModel>[];
      }
      final res = await repo.fetchMemberPayments(
        orgId: workspace.organizationId,
        memberId: memberId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final paymentRefundsProvider = FutureProvider.autoDispose
    .family<List<PaymentRefundModel>, String>((ref, paymentId) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(paymentRepositoryProvider);
      if (workspace == null || repo == null) {
        return const <PaymentRefundModel>[];
      }
      final res = await repo.fetchPaymentRefunds(
        orgId: workspace.organizationId,
        paymentId: paymentId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

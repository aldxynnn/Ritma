import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/booking_models.dart';
import '../domain/booking_repository.dart';
import '../infrastructure/demo_sandbox_booking_repository.dart';
import '../infrastructure/supabase_booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository?>((ref) {
  final mode = ref.watch(appModeProvider);
  switch (mode) {
    case AppMode.supabase:
      final client = ref.watch(supabaseClientProvider);
      return client != null ? SupabaseBookingRepository(client) : null;
    case AppMode.demoSandbox:
      return DemoSandboxBookingRepository(ref.watch(demoSandboxEngineProvider));
    case AppMode.unconfigured:
      return null;
  }
});

final classSessionsProvider =
    FutureProvider.autoDispose<List<ClassSessionModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(bookingRepositoryProvider);
      if (workspace == null || repo == null) {
        return const <ClassSessionModel>[];
      }
      final res = await repo.fetchSessions(
        orgId: workspace.organizationId,
        branchId: workspace.isOperationsSurface ? workspace.branchId : null,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final assignableInstructorsProvider = FutureProvider.autoDispose
    .family<List<AssignableInstructor>, String?>((ref, branchId) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(bookingRepositoryProvider);
      if (workspace == null || repo == null) {
        return const <AssignableInstructor>[];
      }
      final res = await repo.fetchAssignableInstructors(
        orgId: workspace.organizationId,
        branchId: branchId ?? workspace.branchId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final memberBookingsProvider =
    FutureProvider.autoDispose<List<ClassBookingModel>>((ref) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(bookingRepositoryProvider);
      final memberId = workspace?.memberId;
      if (workspace == null || repo == null || memberId == null) {
        return const <ClassBookingModel>[];
      }
      final res = await repo.fetchMemberBookings(
        orgId: workspace.organizationId,
        memberId: memberId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

final sessionRosterProvider = FutureProvider.autoDispose
    .family<List<SessionRosterEntry>, String>((ref, sessionId) async {
      final workspace = ref.watch(activeWorkspaceProvider);
      final repo = ref.watch(bookingRepositoryProvider);
      if (workspace == null || repo == null) {
        return const <SessionRosterEntry>[];
      }
      final res = await repo.fetchSessionRoster(
        orgId: workspace.organizationId,
        sessionId: sessionId,
      );
      return res.when(
        success: (list) => list,
        failure: (failure) => throw AppException(failure),
      );
    });

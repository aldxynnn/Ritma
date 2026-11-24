import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/supabase_provider.dart';
import '../../auth/application/auth_providers.dart';
import '../domain/member_model.dart';
import '../domain/member_repository.dart';
import '../infrastructure/demo_sandbox_member_repository.dart';
import '../infrastructure/supabase_member_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository?>((ref) {
  final mode = ref.watch(appModeProvider);
  switch (mode) {
    case AppMode.supabase:
      final client = ref.watch(supabaseClientProvider);
      return client != null ? SupabaseMemberRepository(client) : null;
    case AppMode.demoSandbox:
      return DemoSandboxMemberRepository(ref.watch(demoSandboxEngineProvider));
    case AppMode.unconfigured:
      return null;
  }
});

class MemberSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

final memberSearchQueryProvider =
    NotifierProvider<MemberSearchQueryNotifier, String>(
      MemberSearchQueryNotifier.new,
    );

class MemberStatusFilterNotifier extends Notifier<MemberStatus?> {
  @override
  MemberStatus? build() => null;

  void setStatus(MemberStatus? status) => state = status;
}

final memberStatusFilterProvider =
    NotifierProvider<MemberStatusFilterNotifier, MemberStatus?>(
      MemberStatusFilterNotifier.new,
    );

final membersListProvider = FutureProvider.autoDispose<List<MemberModel>>((
  ref,
) async {
  final workspace = ref.watch(activeWorkspaceProvider);
  final repo = ref.watch(memberRepositoryProvider);
  final query = ref.watch(memberSearchQueryProvider);
  final status = ref.watch(memberStatusFilterProvider);

  if (workspace == null || repo == null) {
    return const <MemberModel>[];
  }

  final result = await repo.fetchMembers(
    orgId: workspace.organizationId,
    branchId: workspace.branchId,
    query: query,
    statusFilter: status,
  );
  return result.when(
    success: (members) => members,
    failure: (failure) => throw AppException(failure),
  );
});

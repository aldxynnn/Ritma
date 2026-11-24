import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/demo/demo_sandbox_engine.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/members/application/member_providers.dart';
import 'package:ritma/features/members/domain/member_model.dart';

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  test('Member registration, duplicate code guard, search/status filtering, and freeze transitions', () async {
    final container = ProviderContainer(
      overrides: [appEnvProvider.overrideWithValue(demoEnv)],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    await container
        .read(authControllerProvider.notifier)
        .signInWithEmail(email: 'owner@ritma.demo', password: 'RitmaDemo1!');

    final authed =
        container.read(authControllerProvider).asData?.value
            as AuthenticatedSession;
    container
        .read(activeWorkspaceProvider.notifier)
        .select(authed.workspaces.first);

    final repo = container.read(memberRepositoryProvider)!;
    final regRes = await repo.registerMember(
      orgId: DemoSandboxEngine.seedOrgId,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      memberCode: 'RTM-3001',
      fullName: 'Sari Kusuma',
      email: 'sari@ritma.demo',
    );
    expect(regRes.isSuccess, isTrue);
    final member = regRes.when(success: (m) => m, failure: (_) => null)!;

    // Duplicate code fails
    final dupRes = await repo.registerMember(
      orgId: DemoSandboxEngine.seedOrgId,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      memberCode: 'RTM-3001',
      fullName: 'Sari Duplicate',
    );
    expect(
      dupRes.when(success: (_) => null, failure: (f) => f),
      isA<ConflictFailure>(),
    );

    // Search finds Sari
    container.read(memberSearchQueryProvider.notifier).setQuery('Sari');
    var list = await container.read(membersListProvider.future);
    expect(list.map((m) => m.id), contains(member.id));

    // Freeze status & filter
    await repo.setMemberStatus(
      orgId: DemoSandboxEngine.seedOrgId,
      memberId: member.id,
      status: MemberStatus.frozen,
    );
    container.read(memberSearchQueryProvider.notifier).setQuery('');
    container
        .read(memberStatusFilterProvider.notifier)
        .setStatus(MemberStatus.frozen);
    list = await container.read(membersListProvider.future);
    expect(list.length, 1);
    expect(list.first.status, MemberStatus.frozen);
  });
}

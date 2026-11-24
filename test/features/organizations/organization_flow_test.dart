import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/organizations/application/organization_providers.dart';

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  test('Organization creation, multi-branch/room setup, and duplicate branch code rejection', () async {
    final container = ProviderContainer(
      overrides: [appEnvProvider.overrideWithValue(demoEnv)],
    );
    addTearDown(container.dispose);

    await container.read(authControllerProvider.future);
    final authCtrl = container.read(authControllerProvider.notifier);
    await authCtrl.signInWithEmail(
      email: 'new@ritma.demo',
      password: 'RitmaDemo1!',
    );

    final orgRepo = container.read(organizationRepositoryProvider)!;
    final createRes = await orgRepo.createOrganizationWithOwner(
      name: 'Kinetic Collective',
      slug: 'kinetic-collective',
      businessType: 'hybrid',
      timezone: 'Asia/Jakarta',
      currencyCode: 'USD',
      firstBranchName: 'Central Studio',
      firstBranchCode: 'CTR',
    );
    expect(createRes.isSuccess, isTrue);
    final orgId = createRes.when(success: (id) => id, failure: (_) => '');

    await authCtrl.refreshWorkspaces();
    final session =
        container.read(authControllerProvider).asData?.value
            as AuthenticatedSession;
    expect(session.workspaces.length, 1);
    expect(session.workspaces.first.organizationId, orgId);
    expect(session.workspaces.first.roleCode, 'org_owner');

    // Add second branch & room
    final b2Res = await orgRepo.createBranch(
      orgId: orgId,
      name: 'Harbor Gym',
      code: 'HRB',
    );
    expect(b2Res.isSuccess, isTrue);
    final branch2Id = b2Res.when(success: (b) => b.id, failure: (_) => '');

    // Duplicate branch code returns ConflictFailure
    final dupRes = await orgRepo.createBranch(
      orgId: orgId,
      name: 'Harbor Dup',
      code: 'HRB',
    );
    expect(dupRes.isFailure, isTrue);
    final dupFailure = dupRes.when(success: (_) => null, failure: (f) => f);
    expect(dupFailure, isA<ConflictFailure>());

    final roomRes = await orgRepo.createRoom(
      orgId: orgId,
      branchId: branch2Id,
      name: 'Pilates Loft',
      roomType: 'pilates_studio',
      defaultCapacity: 10,
    );
    expect(roomRes.isSuccess, isTrue);

    final branches = await container.read(orgBranchesProvider.future);
    expect(branches.length, 2);

    // Invite staff and verify invite token generation
    final inviteRes = await orgRepo.inviteStaff(
      orgId: orgId,
      email: 'coach@ritma.demo',
      roleCode: 'instructor',
      branchId: branch2Id,
    );
    expect(inviteRes.isSuccess, isTrue);
  });
}

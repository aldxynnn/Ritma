import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/demo/demo_sandbox_engine.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/core/theme/ritma_theme.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/members/application/member_providers.dart';
import 'package:ritma/features/packages/application/package_providers.dart';
import 'package:ritma/features/packages/domain/package_models.dart';
import 'package:ritma/features/shells/presentation/ops_views.dart';

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  test('Strictly separates facility entitlements from class credits, enforces idempotency, freeze/unfreeze, and ledger adjustments', () async {
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

    final memberRepo = container.read(memberRepositoryProvider)!;
    final pkgRepo = container.read(packageEntitlementRepositoryProvider)!;

    // Register two fresh members: one Gym-Only, one Class-Pack-Only
    final gymMember = (await memberRepo.registerMember(
      orgId: DemoSandboxEngine.seedOrgId,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      memberCode: 'GYM-1',
      fullName: 'Gym Only User',
    )).when(success: (m) => m, failure: (_) => null)!;

    final studioMember = (await memberRepo.registerMember(
      orgId: DemoSandboxEngine.seedOrgId,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      memberCode: 'CLS-1',
      fullName: 'Pilates Only User',
    )).when(success: (m) => m, failure: (_) => null)!;

    final packages = await container.read(orgPackagesProvider.future);
    final gymPkg = packages.firstWhere(
      (p) => p.packageType == PackageType.gymMembership,
    );
    final classPkg = packages.firstWhere(
      (p) => p.packageType == PackageType.classPack,
    );

    // 1. Gym-Only package -> Facility Access YES, Class Credits 0
    final gymSubRes = await pkgRepo.assignPackageToMember(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      memberId: gymMember.id,
      packageId: gymPkg.id,
      paymentMethod: PaymentMethod.cash,
      idempotencyKey: 'assign-gym-key-1',
    );
    expect(gymSubRes.isSuccess, isTrue);

    final gymWallet = await container.read(
      memberWalletProvider(gymMember.id).future,
    );
    expect(gymWallet.hasActiveFacilityAccess, isTrue);
    expect(gymWallet.totalClassCredits, 0);
    expect(gymWallet.ledgerEntries, isEmpty);

    // 2. Class-Pack-Only -> Facility Access NO, Class Credits 10 + grant ledger entry
    final clsSubId = (await pkgRepo.assignPackageToMember(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      memberId: studioMember.id,
      packageId: classPkg.id,
      paymentMethod: PaymentMethod.cardTerminal,
      idempotencyKey: 'assign-cls-key-1',
    )).when(success: (id) => id, failure: (_) => '');

    // Replay with same key does not duplicate grants
    final replayId = (await pkgRepo.assignPackageToMember(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      memberId: studioMember.id,
      packageId: classPkg.id,
      paymentMethod: PaymentMethod.cardTerminal,
      idempotencyKey: 'assign-cls-key-1',
    )).when(success: (id) => id, failure: (_) => '');
    expect(replayId, clsSubId);

    var studioWallet = await container.read(
      memberWalletProvider(studioMember.id).future,
    );
    expect(studioWallet.hasActiveFacilityAccess, isFalse);
    expect(studioWallet.totalClassCredits, 10);
    expect(studioWallet.ledgerEntries.length, 1);
    expect(studioWallet.ledgerEntries.first.delta, 10);

    // 3. Freezing subscription freezes credit grants too; unfreezing restores
    await pkgRepo.freezeSubscription(
      orgId: DemoSandboxEngine.seedOrgId,
      subscriptionId: clsSubId,
    );
    container.invalidate(memberWalletProvider(studioMember.id));
    studioWallet = await container.read(
      memberWalletProvider(studioMember.id).future,
    );
    expect(studioWallet.totalClassCredits, 0);

    await pkgRepo.unfreezeSubscription(
      orgId: DemoSandboxEngine.seedOrgId,
      subscriptionId: clsSubId,
    );
    container.invalidate(memberWalletProvider(studioMember.id));
    studioWallet = await container.read(
      memberWalletProvider(studioMember.id).future,
    );
    expect(studioWallet.totalClassCredits, 10);

    // 4. Credit adjustment appends ledger entry & blocks over-debit
    await pkgRepo.adjustMemberCredits(
      orgId: DemoSandboxEngine.seedOrgId,
      memberId: studioMember.id,
      creditType: CreditType.classCredit,
      delta: -3,
      reason: 'Comp adjustment test',
      idempotencyKey: 'adj-1',
    );
    container.invalidate(memberWalletProvider(studioMember.id));
    studioWallet = await container.read(
      memberWalletProvider(studioMember.id).future,
    );
    expect(studioWallet.totalClassCredits, 7);
    expect(studioWallet.ledgerEntries.length, 2);

    final overDebit = await pkgRepo.adjustMemberCredits(
      orgId: DemoSandboxEngine.seedOrgId,
      memberId: studioMember.id,
      creditType: CreditType.classCredit,
      delta: -99,
      reason: 'Over debit attempt',
      idempotencyKey: 'adj-2',
    );
    expect(
      overDebit.when(success: (_) => null, failure: (f) => f),
      isA<ConflictFailure>(),
    );
  });

  testWidgets('OpsMembersView switches cleanly between Members and Packages', (
    tester,
  ) async {
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: RitmaTheme.light(),
          home: const Scaffold(body: OpsMembersView()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Member Directory'), findsOneWidget);
    expect(find.text('Alina Santoso'), findsOneWidget);

    await tester.tap(find.text('Packages'));
    await tester.pumpAndSettle();
    expect(find.text('Open Gym Monthly (Single Branch)'), findsOneWidget);
    expect(find.text('10-Class Pilates Pack'), findsOneWidget);
  });
}

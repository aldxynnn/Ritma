import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/demo/demo_sandbox_engine.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/core/theme/ritma_spacing.dart';
import 'package:ritma/core/theme/ritma_theme.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/members/application/member_providers.dart';
import 'package:ritma/features/operations_extras/application/operations_extras_providers.dart';
import 'package:ritma/features/operations_extras/domain/operations_extras_models.dart';
import 'package:ritma/features/operations_extras/presentation/equipment_operations_screen.dart';
import 'package:ritma/features/operations_extras/presentation/notifications_sheet.dart';
import 'package:ritma/features/packages/application/package_providers.dart';
import 'package:ritma/features/packages/domain/package_models.dart';
import 'package:ritma/features/payments/application/payment_providers.dart';
import 'package:ritma/features/payments/domain/payment_record_model.dart';
import 'package:ritma/features/payments/presentation/payments_ledger_view.dart';
import 'package:ritma/features/personal_training/application/pt_providers.dart';
import 'package:ritma/features/personal_training/domain/pt_models.dart';
import 'package:ritma/features/personal_training/presentation/pt_sessions_view.dart';

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  test('Wave 3 domains: PT credits isolation, trainer availability/conflicts, payments ledger, equipment tickets, and notifications', () async {
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
    final ownerWs = authed.workspaces.firstWhere(
      (w) => w.roleCode == 'org_owner',
    );
    container.read(activeWorkspaceProvider.notifier).select(ownerWs);

    final memberRepo = container.read(memberRepositoryProvider)!;
    final pkgRepo = container.read(packageEntitlementRepositoryProvider)!;
    final ptRepo = container.read(ptRepositoryProvider)!;
    final opsExtrasRepo = container.read(operationsExtrasRepositoryProvider)!;

    // Register member with ONLY class credits first
    final studioOnlyMember = (await memberRepo.registerMember(
      orgId: DemoSandboxEngine.seedOrgId,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      memberCode: 'W3-CLS',
      fullName: 'Class Only Patron',
    )).when(success: (m) => m, failure: (_) => null)!;

    final ptMember = (await memberRepo.registerMember(
      orgId: DemoSandboxEngine.seedOrgId,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      memberCode: 'W3-PT',
      fullName: 'Private Coaching Member',
    )).when(success: (m) => m, failure: (_) => null)!;

    final packages = await container.read(orgPackagesProvider.future);
    final classPack = packages.firstWhere(
      (p) => p.packageType == PackageType.classPack,
    );
    final ptPack = packages.firstWhere(
      (p) => p.packageType == PackageType.ptPack,
    );

    await pkgRepo.assignPackageToMember(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      memberId: studioOnlyMember.id,
      packageId: classPack.id,
      paymentMethod: PaymentMethod.cash,
      idempotencyKey: 'w3-cls-assign',
    );
    await pkgRepo.assignPackageToMember(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      memberId: ptMember.id,
      packageId: ptPack.id,
      paymentMethod: PaymentMethod.cardTerminal,
      idempotencyKey: 'w3-pt-assign',
    );

    final trainers = await container.read(orgTrainersProvider.future);
    expect(trainers, isNotEmpty);
    final trainer = trainers.first;

    final twoDaysOut = DateTime.now().toUtc().add(const Duration(days: 2));
    // 03:00 UTC == 10:00 Asia/Jakarta (inside 06:00-22:00 window)
    final validStart = DateTime.utc(
      twoDaysOut.year,
      twoDaysOut.month,
      twoDaysOut.day,
      3,
      0,
    );
    final validEnd = validStart.add(const Duration(hours: 1));
    // 19:00 UTC == 02:00 Asia/Jakarta next day (outside availability)
    final outsideStart = DateTime.utc(
      twoDaysOut.year,
      twoDaysOut.month,
      twoDaysOut.day,
      19,
      0,
    );
    final outsideEnd = outsideStart.add(const Duration(hours: 1));

    // Class-only member CANNOT use class credits to book a PT session
    final clsCannotBookPt = await ptRepo.bookPtSession(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: trainer.homeBranchId,
      trainerId: trainer.id,
      memberId: studioOnlyMember.id,
      startsAt: validStart,
      endsAt: validEnd,
      idempotencyKey: 'pt-cls-deny',
    );
    expect(
      clsCannotBookPt.when(success: (_) => null, failure: (f) => f),
      isA<ConflictFailure>(),
    );

    // Outside trainer availability fails validation
    final outsideRes = await ptRepo.bookPtSession(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: trainer.homeBranchId,
      trainerId: trainer.id,
      memberId: ptMember.id,
      startsAt: outsideStart,
      endsAt: outsideEnd,
      idempotencyKey: 'pt-outside',
    );
    expect(
      outsideRes.when(success: (_) => null, failure: (f) => f),
      isA<ValidationFailure>(),
    );

    // Valid PT booking succeeds, debits 1 PT credit (5 -> 4), and replays idempotently
    final booked = (await ptRepo.bookPtSession(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: trainer.homeBranchId,
      trainerId: trainer.id,
      memberId: ptMember.id,
      startsAt: validStart,
      endsAt: validEnd,
      idempotencyKey: 'pt-valid-1',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(booked.status, PtSessionStatus.scheduled);
    expect(booked.idempotentReplay, isFalse);

    final replayed = (await ptRepo.bookPtSession(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: trainer.homeBranchId,
      trainerId: trainer.id,
      memberId: ptMember.id,
      startsAt: validStart,
      endsAt: validEnd,
      idempotencyKey: 'pt-valid-1',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(replayed.idempotentReplay, isTrue);

    final walletAfterBook = await pkgRepo
        .fetchMemberWallet(
          orgId: DemoSandboxEngine.seedOrgId,
          memberId: ptMember.id,
        )
        .then((r) => r.when(success: (w) => w, failure: (_) => null)!);
    expect(walletAfterBook.totalPtCredits, 4);

    // Overlapping slot for trainer fails
    final overlapRes = await ptRepo.bookPtSession(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: trainer.homeBranchId,
      trainerId: trainer.id,
      memberId: ptMember.id,
      startsAt: validStart.add(const Duration(minutes: 30)),
      endsAt: validEnd.add(const Duration(minutes: 30)),
      idempotencyKey: 'pt-overlap',
    );
    expect(
      overlapRes.when(success: (_) => null, failure: (f) => f),
      isA<ConflictFailure>(),
    );

    // Complete PT session with notes
    final compRes = await ptRepo.completePtSession(
      orgId: DemoSandboxEngine.seedOrgId,
      ptSessionId: booked.ptSessionId,
      notes: 'RPE 8 back squat progression',
    );
    expect(compRes.isSuccess, isTrue);

    final sessions = await container.read(ptSessionsProvider.future);
    final donePt = sessions.firstWhere((s) => s.id == booked.ptSessionId);
    expect(donePt.status, PtSessionStatus.completed);
    expect(donePt.notes, 'RPE 8 back squat progression');

    // Payments ledger verifies recorded package purchases
    final orgPayments = await container.read(orgPaymentsProvider.future);
    expect(
      orgPayments.any(
        (p) =>
            p.memberId == ptMember.id &&
            p.amountMinor == ptPack.priceMinor &&
            p.method == PaymentMethod.cardTerminal &&
            p.status == PaymentStatus.paid,
      ),
      isTrue,
    );

    // Equipment assets & maintenance ticket lifecycle
    final asset = (await opsExtrasRepo.createEquipmentAsset(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      assetCode: 'DTN-DB-10',
      name: 'Competition Dumbbell Set',
      category: 'Free Weights',
    )).when(success: (a) => a, failure: (_) => null)!;
    expect(asset.status, EquipmentStatus.operational);

    final ticket = (await opsExtrasRepo.createMaintenanceTicket(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      assetId: asset.id,
      summary: 'Loose knurling collar on 22kg pair',
      priority: TicketPriority.high,
    )).when(success: (t) => t, failure: (_) => null)!;
    expect(ticket.status, TicketStatus.open);

    final resolved = (await opsExtrasRepo.updateTicketStatus(
      orgId: DemoSandboxEngine.seedOrgId,
      ticketId: ticket.id,
      status: TicketStatus.resolved,
    )).when(success: (t) => t, failure: (_) => null)!;
    expect(resolved.status, TicketStatus.resolved);
    expect(resolved.resolvedAt, isNotNull);

    // Notifications read update
    var notifications = await container.read(userNotificationsProvider.future);
    final unread = notifications.where((n) => n.readAt == null).toList();
    expect(unread, isNotEmpty);

    final markRes = await opsExtrasRepo.markNotificationRead(
      notificationId: unread.first.id,
    );
    expect(markRes.isSuccess, isTrue);
    container.invalidate(userNotificationsProvider);
    notifications = await container.read(userNotificationsProvider.future);
    expect(
      notifications.firstWhere((n) => n.id == unread.first.id).readAt,
      isNotNull,
    );
  });

  testWidgets(
    'Wave 3 UI widgets render cleanly in dark mode at 1.5x text scale without overflow',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

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
      final ownerWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'org_owner',
      );
      container.read(activeWorkspaceProvider.notifier).select(ownerWs);

      Widget wrap(Widget child) {
        return UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: RitmaTheme.dark(density: RitmaDensity.operations),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(1024, 900),
                textScaler: TextScaler.linear(1.5),
              ),
              child: child,
            ),
          ),
        );
      }

      await tester.pumpWidget(wrap(const Scaffold(body: PtSessionsView())));
      await tester.pumpAndSettle();
      expect(find.text('Personal Training'), findsOneWidget);
      expect(find.text('Active Trainers'), findsOneWidget);

      await tester.pumpWidget(wrap(const Scaffold(body: PaymentsLedgerView())));
      await tester.pumpAndSettle();
      expect(find.text('Payments Ledger'), findsOneWidget);

      await tester.pumpWidget(wrap(const EquipmentOperationsScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Equipment & Maintenance'), findsOneWidget);
      expect(
        find.text('Merrithew V2 Max Reformer #1 (DTN-RF-01)'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        wrap(
          Scaffold(appBar: AppBar(actions: const [NotificationsBellButton()])),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsOneWidget);
    },
  );
}

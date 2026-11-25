import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/demo/demo_sandbox_engine.dart';
import 'package:ritma/core/errors/error_mapper.dart';
import 'package:ritma/core/export/csv_exporter.dart';
import 'package:ritma/core/utils/postgrest_filter_utils.dart';
import 'package:ritma/core/utils/ritma_timezone.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/auth/domain/auth_user.dart';
import 'package:ritma/features/auth/domain/ritma_role.dart';
import 'package:ritma/features/auth/domain/user_profile.dart';
import 'package:ritma/features/booking/presentation/member_schedule_view.dart';
import 'package:ritma/features/booking/presentation/ops_schedule_roster_view.dart';
import 'package:ritma/features/dashboard/domain/report_export_model.dart';
import 'package:ritma/features/facility_access/presentation/qr_scanner_sheet.dart';
import 'package:ritma/features/members/infrastructure/demo_sandbox_member_repository.dart';
import 'package:ritma/features/packages/domain/package_models.dart';
import 'package:ritma/features/packages/presentation/packages_catalog_view.dart';
import 'package:ritma/features/payments/domain/payment_record_model.dart';
import 'package:ritma/features/personal_training/domain/pt_models.dart';

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  DemoSandboxEngine createSeededEngine() => DemoSandboxEngine();

  test('Area A: PT trainer isolation, member lookup names & cancel refund', () {
    final engine = createSeededEngine();
    engine.currentUser = DemoSandboxEngine.ownerUser;

    // Seed two Personal Trainers on the same branch (Downtown)
    const pt1Id = 'pt-user-1';
    const pt2Id = 'pt-user-2';
    const pt1User = AuthUser(
      id: pt1Id,
      email: 'pt1@ritma.demo',
      fullName: 'Coach Maya',
    );
    const pt2User = AuthUser(
      id: pt2Id,
      email: 'pt2@ritma.demo',
      fullName: 'Coach Dimas',
    );
    engine.usersByEmail[pt1User.email] = pt1User;
    engine.usersByEmail[pt2User.email] = pt2User;
    engine.profiles[pt1Id] = const UserProfile(
      userId: pt1Id,
      fullName: 'Coach Maya',
    );
    engine.profiles[pt2Id] = const UserProfile(
      userId: pt2Id,
      fullName: 'Coach Dimas',
    );

    engine.assignUserRole(
      orgId: DemoSandboxEngine.seedOrgId,
      targetUserId: pt1Id,
      roleCode: RitmaRole.personalTrainer.code,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
    );
    engine.assignUserRole(
      orgId: DemoSandboxEngine.seedOrgId,
      targetUserId: pt2Id,
      roleCode: RitmaRole.personalTrainer.code,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
    );

    const tp1 = 'tp-maya';
    const tp2 = 'tp-dimas';
    engine.trainerProfiles[tp1] = const TrainerProfileModel(
      id: tp1,
      organizationId: DemoSandboxEngine.seedOrgId,
      userId: pt1Id,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      displayName: 'Coach Maya',
      defaultCreditCost: 1,
    );
    engine.trainerProfiles[tp2] = const TrainerProfileModel(
      id: tp2,
      organizationId: DemoSandboxEngine.seedOrgId,
      userId: pt2Id,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      displayName: 'Coach Dimas',
      defaultCreditCost: 1,
    );
    for (var d = 0; d <= 6; d++) {
      engine.trainerAvailabilities.add(
        TrainerAvailabilityModel(
          id: 'ta-1-$d',
          organizationId: DemoSandboxEngine.seedOrgId,
          branchId: DemoSandboxEngine.seedBranchDowntownId,
          trainerId: tp1,
          weekday: d,
          startTime: '06:00:00',
          endTime: '22:00:00',
        ),
      );
      engine.trainerAvailabilities.add(
        TrainerAvailabilityModel(
          id: 'ta-2-$d',
          organizationId: DemoSandboxEngine.seedOrgId,
          branchId: DemoSandboxEngine.seedBranchDowntownId,
          trainerId: tp2,
          weekday: d,
          startTime: '06:00:00',
          endTime: '22:00:00',
        ),
      );
    }

    // Grant 3 PT credits to Alina (seed member)
    final memberId = engine.members.values.first.id;
    final ptPkg = engine.createPackage(
      orgId: DemoSandboxEngine.seedOrgId,
      name: 'PT 3 Pack',
      description: '',
      packageType: PackageType.ptPack,
      priceMinor: 12000,
      currencyCode: 'USD',
      rules: const [
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.ptCredit,
          durationDays: 60,
          creditQuantity: 3,
          branchAccessScope: BranchAccessScope.allBranches,
        ),
      ],
    );
    engine.assignPackageToMember(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      memberId: memberId,
      packageId: ptPkg.id,
      paymentMethod: PaymentMethod.cash,
      idempotencyKey: 'pt-pack-assign-1',
    );

    // PT 1 looks up members and books for PT 1
    engine.currentUser = pt1User;
    final lookup = engine.lookupMembersForPtBooking(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      query: engine.members[memberId]!.memberCode,
    );
    expect(lookup, hasLength(1));
    expect(lookup.first.fullName, engine.members[memberId]!.fullName);
    expect(lookup.first.availablePtCredits, 3);

    final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1));
    final slotStart = DateTime.utc(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      10,
    );
    final slotEnd = slotStart.add(const Duration(hours: 1));

    // PT 1 cannot book on behalf of PT 2
    expect(
      () => engine.bookPtSession(
        orgId: DemoSandboxEngine.seedOrgId,
        branchId: DemoSandboxEngine.seedBranchDowntownId,
        trainerId: tp2,
        memberId: memberId,
        startsAt: slotStart,
        endsAt: slotEnd,
        idempotencyKey: 'pt1-hijack-pt2',
      ),
      throwsA(isA<AppException>()),
    );

    // PT 1 books valid session
    final booked = engine.bookPtSession(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      trainerId: tp1,
      memberId: memberId,
      startsAt: slotStart,
      endsAt: slotEnd,
      idempotencyKey: 'pt1-valid-1',
    );
    expect(booked.creditCost, 1);

    // PT 1 sees resolved member name & code (never UUID fallback)
    final pt1List = engine.fetchPtSessions(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
    );
    expect(pt1List, hasLength(1));
    expect(pt1List.first.memberDisplayName, engine.members[memberId]!.fullName);
    expect(pt1List.first.memberCode, engine.members[memberId]!.memberCode);

    // PT 2 sees 0 sessions and cannot complete or cancel PT 1's session
    engine.currentUser = pt2User;
    expect(
      engine.fetchPtSessions(
        orgId: DemoSandboxEngine.seedOrgId,
        branchId: DemoSandboxEngine.seedBranchDowntownId,
      ),
      isEmpty,
    );
    expect(
      () => engine.completePtSession(
        orgId: DemoSandboxEngine.seedOrgId,
        ptSessionId: booked.ptSessionId,
      ),
      throwsA(isA<AppException>()),
    );
    expect(
      () => engine.cancelPtSession(
        orgId: DemoSandboxEngine.seedOrgId,
        ptSessionId: booked.ptSessionId,
      ),
      throwsA(isA<AppException>()),
    );

    // PT 1 cancels own session -> 1 credit refunded (back to 3)
    engine.currentUser = pt1User;
    final cancelled = engine.cancelPtSession(
      orgId: DemoSandboxEngine.seedOrgId,
      ptSessionId: booked.ptSessionId,
      reason: 'Client rescheduled',
    );
    expect(cancelled.status, PtSessionStatus.cancelledEarly);
    expect(cancelled.refundedCredits, 1);
    final afterCancelLookup = engine.lookupMembersForPtBooking(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      query: engine.members[memberId]!.memberCode,
    );
    expect(afterCancelLookup.first.availablePtCredits, 3);
  });

  test(
    'Area C: Selected Branches requires >=1 branch & updates atomically',
    () {
      final engine = createSeededEngine();
      engine.currentUser = DemoSandboxEngine.ownerUser;

      // Empty allowedBranchIds rejected on createPackage
      expect(
        () => engine.createPackage(
          orgId: DemoSandboxEngine.seedOrgId,
          name: 'Broken Selected',
          description: '',
          packageType: PackageType.gymMembership,
          priceMinor: 5000,
          currencyCode: 'USD',
          rules: const [
            CreatePackageRuleInput(
              entitlementKind: EntitlementKind.facilityAccess,
              durationDays: 30,
              branchAccessScope: BranchAccessScope.selectedBranches,
              allowedBranchIds: <String>[],
            ),
          ],
        ),
        throwsA(isA<AppException>()),
      );

      // Valid selectedBranches creation & edit via updatePackageDetails
      final created = engine.createPackage(
        orgId: DemoSandboxEngine.seedOrgId,
        name: 'Downtown Only Pass',
        description: 'Valid selected branch pass',
        packageType: PackageType.gymMembership,
        priceMinor: 5500,
        currencyCode: 'USD',
        rules: const [
          CreatePackageRuleInput(
            entitlementKind: EntitlementKind.facilityAccess,
            durationDays: 30,
            branchAccessScope: BranchAccessScope.selectedBranches,
            allowedBranchIds: <String>[DemoSandboxEngine.seedBranchDowntownId],
          ),
        ],
      );
      expect(
        created.rules.first.allowedBranchIds,
        contains(DemoSandboxEngine.seedBranchDowntownId),
      );

      engine.updatePackageDetails(
        orgId: DemoSandboxEngine.seedOrgId,
        packageId: created.id,
        name: 'Westside Updated Pass',
        description: 'Switched branch',
        priceMinor: 6000,
        isActive: true,
        branchAccessScope: BranchAccessScope.selectedBranches,
        allowedBranchIds: const [DemoSandboxEngine.seedBranchWestsideId],
      );
      final updated = engine.packages[created.id]!;
      expect(updated.name, 'Westside Updated Pass');
      expect(updated.rules.first.allowedBranchIds, [
        DemoSandboxEngine.seedBranchWestsideId,
      ]);
    },
  );

  test('Area E: Member claim token, member edit & QR key rotation', () {
    final engine = createSeededEngine();
    engine.currentUser = DemoSandboxEngine.ownerUser;

    final unlinked = engine.registerMember(
      orgId: DemoSandboxEngine.seedOrgId,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      memberCode: 'RTM-8801',
      fullName: 'Citra Ayu',
      email: 'new@ritma.demo',
    );
    final pkg = engine.packages.values.first;
    engine.assignPackageToMember(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      memberId: unlinked.id,
      packageId: pkg.id,
      paymentMethod: PaymentMethod.cash,
      idempotencyKey: 'claim-pkg-1',
    );

    final token = engine.inviteMemberClaim(
      orgId: DemoSandboxEngine.seedOrgId,
      memberId: unlinked.id,
      email: 'new@ritma.demo',
    );

    engine.currentUser = DemoSandboxEngine.emptyUser;
    engine.claimMemberProfile(token);
    expect(engine.members[unlinked.id]!.userId, DemoSandboxEngine.emptyUser.id);

    // Reusing claim token fails
    expect(
      () => engine.claimMemberProfile(token),
      throwsA(isA<AppException>()),
    );

    // Rotate signing key invalidates previously issued QR pass
    final oldQr = engine.issueMemberQrToken(
      orgId: DemoSandboxEngine.seedOrgId,
      memberId: unlinked.id,
    );
    engine.currentUser = DemoSandboxEngine.ownerUser;
    engine.rotateOrgSigningKey(DemoSandboxEngine.seedOrgId);
    final checkOutcome = engine.validateAndCheckIn(
      orgId: DemoSandboxEngine.seedOrgId,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
      qrToken: oldQr.token,
      idempotencyKey: 'qr-after-rotate',
    );
    expect(checkOutcome.allowed, isFalse);
    expect(checkOutcome.reasonCode, 'QR_INVALID_SIGNATURE');

    // Update member contact fields
    final edited = engine.updateMember(
      orgId: DemoSandboxEngine.seedOrgId,
      memberId: unlinked.id,
      homeBranchId: DemoSandboxEngine.seedBranchDowntownId,
      fullName: 'Citra Ayu Pratama',
      email: 'new@ritma.demo',
      phone: '+628111222333',
      emergencyContactName: 'Budi',
      emergencyContactPhone: '+628999',
    );
    expect(edited.fullName, 'Citra Ayu Pratama');
    expect(edited.emergencyContactName, 'Budi');
  });

  test(
    'Area H & I: CSV formula injection escaping, manual refunds & net revenue',
    () {
      // Formula-injection neutralization
      final csv = CsvExporter.buildCsvString(
        columns: const ['Member', 'Amount'],
        rows: const [
          ['=CMD|calc!A0', '-100+2'],
          ['+SUM(A1)', '@malicious'],
          ['\t=tab', '\r=cr'],
          ['Normal, "Quoted" Name', '50.00'],
        ],
      );
      expect(csv, contains("'=CMD|calc!A0"));
      expect(csv, contains("'-100+2"));
      expect(csv, contains("'+SUM(A1)"));
      expect(csv, contains("'@malicious"));
      expect(csv, contains("'\t=tab"));
      expect(csv, contains("'\r=cr"));
      expect(csv, contains('"Normal, ""Quoted"" Name"'));

      // Partial/Full/Over-refund guards + Net Dashboard Revenue + Report scope isolation
      final engine = createSeededEngine();
      engine.currentUser = DemoSandboxEngine.ownerUser;

      final memberId = engine.members.values.first.id;
      final pkg = engine.createPackage(
        orgId: DemoSandboxEngine.seedOrgId,
        name: 'Refund Test Pack',
        description: '',
        packageType: PackageType.classPack,
        priceMinor: 10000,
        currencyCode: 'USD',
        rules: const [
          CreatePackageRuleInput(
            entitlementKind: EntitlementKind.classCredit,
            durationDays: 30,
            creditQuantity: 5,
            branchAccessScope: BranchAccessScope.allBranches,
          ),
        ],
      );
      final subId = engine.assignPackageToMember(
        orgId: DemoSandboxEngine.seedOrgId,
        branchId: DemoSandboxEngine.seedBranchDowntownId,
        memberId: memberId,
        packageId: pkg.id,
        paymentMethod: PaymentMethod.cardTerminal,
        idempotencyKey: 'refund-assign-1',
      );
      final pay = engine.paymentRecords.firstWhere(
        (p) => p.subscriptionId == subId,
      );
      final kpiBefore = engine.getOperationalDashboardMetrics(
        orgId: DemoSandboxEngine.seedOrgId,
      );

      // Partial $40 refund -> manual_recorded, net revenue reduces by 4000
      final r1 = engine.recordPaymentRefund(
        orgId: DemoSandboxEngine.seedOrgId,
        paymentId: pay.id,
        amountMinor: 4000,
        reason: 'Partial credit',
        idempotencyKey: 'ref-key-1',
      );
      expect(r1.refundChannel, 'manual_recorded');
      expect(r1.paymentStatus, PaymentStatus.paid);
      final kpiAfterPartial = engine.getOperationalDashboardMetrics(
        orgId: DemoSandboxEngine.seedOrgId,
      );
      expect(
        kpiAfterPartial.windowRevenueMinor,
        kpiBefore.windowRevenueMinor - 4000,
      );

      // Idempotent replay does not double refund
      final replay = engine.recordPaymentRefund(
        orgId: DemoSandboxEngine.seedOrgId,
        paymentId: pay.id,
        amountMinor: 4000,
        reason: 'Partial credit',
        idempotencyKey: 'ref-key-1',
      );
      expect(replay.idempotentReplay, isTrue);

      // Over-refund fails
      expect(
        () => engine.recordPaymentRefund(
          orgId: DemoSandboxEngine.seedOrgId,
          paymentId: pay.id,
          amountMinor: 7000,
          reason: 'Too much',
          idempotencyKey: 'ref-key-over',
        ),
        throwsA(isA<AppException>()),
      );

      // Remaining $60 marks payment refunded
      final r2 = engine.recordPaymentRefund(
        orgId: DemoSandboxEngine.seedOrgId,
        paymentId: pay.id,
        amountMinor: 6000,
        reason: 'Final refund',
        idempotencyKey: 'ref-key-2',
      );
      expect(r2.paymentStatus, PaymentStatus.refunded);
      expect(
        engine.fetchPaymentRefunds(
          orgId: DemoSandboxEngine.seedOrgId,
          paymentId: pay.id,
        ),
        hasLength(2),
      );

      // Duplicate refund after full refund fails
      expect(
        () => engine.recordPaymentRefund(
          orgId: DemoSandboxEngine.seedOrgId,
          paymentId: pay.id,
          amountMinor: 100,
          reason: 'Duplicate',
          idempotencyKey: 'ref-key-dup',
        ),
        throwsA(isA<AppException>()),
      );

      // Member-only user denied report export
      engine.currentUser = DemoSandboxEngine.memberUser;
      expect(
        () => engine.getReportExportData(
          orgId: DemoSandboxEngine.seedOrgId,
          reportType: ReportExportType.payments,
        ),
        throwsA(isA<AppException>()),
      );
    },
  );

  test('Area B & J: Assignable instructors, session edit, staff hierarchy', () {
    final engine = createSeededEngine();
    engine.currentUser = DemoSandboxEngine.ownerUser;

    // Assignable instructors includes owner/instructor accounts
    final instructors = engine.fetchAssignableInstructors(
      orgId: DemoSandboxEngine.seedOrgId,
    );
    expect(instructors, isNotEmpty);

    // Update class session persists instructorUserId
    final session = engine.classSessions.values.first;
    final edited = engine.updateClassSession(
      orgId: DemoSandboxEngine.seedOrgId,
      sessionId: session.id,
      roomId: session.roomId,
      classTypeId: session.classTypeId,
      title: 'Updated Reformer Class',
      startsAt: session.startsAt,
      endsAt: session.endsAt,
      capacity: session.capacity,
      creditCost: session.creditCost,
      cancellationCutoffAt: session.cancellationCutoffAt,
      waitlistEnabled: session.waitlistEnabled,
      instructorUserId: DemoSandboxEngine.ownerUser.id,
      instructorDisplayName: 'Alina Santoso',
    );
    expect(edited.title, 'Updated Reformer Class');
    expect(edited.instructorUserId, DemoSandboxEngine.ownerUser.id);

    // Staff management + invite revocation + last owner guard
    final staff = engine.fetchOrganizationStaff(
      orgId: DemoSandboxEngine.seedOrgId,
    );
    expect(staff, isNotEmpty);
    final ownerAssignment = staff.firstWhere((s) => s.roleCode == 'org_owner');
    expect(
      () => engine.revokeUserRole(
        orgId: DemoSandboxEngine.seedOrgId,
        assignmentId: ownerAssignment.assignmentId,
      ),
      throwsA(isA<AppException>()),
    );

    final inv = engine.inviteStaff(
      orgId: DemoSandboxEngine.seedOrgId,
      email: 'staff.new@ritma.demo',
      roleCode: RitmaRole.receptionist.code,
      branchId: DemoSandboxEngine.seedBranchDowntownId,
    );
    final pendingBefore = engine.fetchOrganizationInvitations(
      orgId: DemoSandboxEngine.seedOrgId,
    );
    expect(pendingBefore.any((i) => i.id == inv.invitationId), isTrue);

    engine.revokeOrganizationInvitation(
      orgId: DemoSandboxEngine.seedOrgId,
      invitationId: inv.invitationId,
    );
    final pendingAfter = engine.fetchOrganizationInvitations(
      orgId: DemoSandboxEngine.seedOrgId,
    );
    expect(pendingAfter.any((i) => i.id == inv.invitationId), isFalse);
  });

  test(
    'Area F: RitmaTimezone wall-clock WIB conversions & currency formatting',
    () {
      final utcInstant = DateTime.utc(2026, 11, 25, 3, 0); // 10:00 WIB
      expect(
        RitmaTimezone.formatTime(utcInstant, 'Asia/Jakarta', includeZone: true),
        '10:00 WIB',
      );
      expect(
        RitmaTimezone.fromOrgWallClock(
          year: 2026,
          month: 11,
          day: 25,
          hour: 10,
          timezone: 'Asia/Jakarta',
        ),
        utcInstant,
      );
      expect(RitmaTimezone.formatMoney(205500, 'USD'), r'$2,055.00');
    },
  );

  testWidgets(
    'Area F & B UI: MemberSchedule hides past classes & Instructor only sees assigned classes',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer(
        overrides: [appEnvProvider.overrideWithValue(demoEnv)],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      await container
          .read(authControllerProvider.notifier)
          .signInWithEmail(email: 'owner@ritma.demo', password: 'RitmaDemo1!');

      final engine = container.read(demoSandboxEngineProvider);
      final pastStart = DateTime.now().toUtc().subtract(
        const Duration(hours: 5),
      );
      engine.createClassSession(
        orgId: DemoSandboxEngine.seedOrgId,
        branchId: DemoSandboxEngine.seedBranchDowntownId,
        roomId: '33333333-3333-3333-3333-333333333301',
        classTypeId: engine.classTypes.keys.first,
        title: 'Yesterday Hidden Class',
        startsAt: pastStart,
        endsAt: pastStart.add(const Duration(hours: 1)),
        capacity: 10,
        creditCost: 1,
        cancellationCutoffAt: pastStart.subtract(const Duration(hours: 2)),
        instructorUserId: null,
        instructorDisplayName: 'Guest Coach',
      );
      engine.createClassSession(
        orgId: DemoSandboxEngine.seedOrgId,
        branchId: DemoSandboxEngine.seedBranchWestsideId,
        roomId: '33333333-3333-3333-3333-333333333302',
        classTypeId: engine.classTypes.keys.first,
        title: 'Other Instructor Future Class',
        startsAt: DateTime.now().toUtc().add(const Duration(hours: 20)),
        endsAt: DateTime.now().toUtc().add(const Duration(hours: 21)),
        capacity: 10,
        creditCost: 1,
        cancellationCutoffAt: DateTime.now().toUtc().add(
          const Duration(hours: 18),
        ),
        instructorUserId: 'someone-else',
        instructorDisplayName: 'Other Coach',
      );

      final authed =
          container.read(authControllerProvider).asData!.value
              as AuthenticatedSession;

      // 1) Member schedule hides past classes while keeping upcoming classes
      final memberWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'member',
      );
      container.read(activeWorkspaceProvider.notifier).select(memberWs);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: MemberScheduleBrowseView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Yesterday Hidden Class'), findsNothing);
      expect(find.text('Morning Reformer Foundations'), findsOneWidget);

      // 2) Instructor workspace only sees sessions assigned to ownerUser.id
      final instrWs = authed.workspaces.firstWhere(
        (w) => w.roleCode == 'instructor',
      );
      container.read(activeWorkspaceProvider.notifier).select(instrWs);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: OpsScheduleRosterView()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kinetic Conditioning 50'), findsOneWidget);
      expect(find.text('Other Instructor Future Class'), findsNothing);
    },
  );

  testWidgets('Area C UI: PackagesCatalog shows Selected Branches checklist', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
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
        container.read(authControllerProvider).asData!.value
            as AuthenticatedSession;
    container
        .read(activeWorkspaceProvider.notifier)
        .select(authed.workspaces.firstWhere((w) => w.roleCode == 'org_owner'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: PackagesCatalogView())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New Package'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Single Branch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selected Branches').last);
    await tester.pumpAndSettle();

    expect(find.text('Allowed Branches (select at least one)'), findsOneWidget);
    expect(find.textContaining('Downtown Studio'), findsOneWidget);

    // Unchecking the auto-seeded first branch must stay unchecked so user can pick branch 2 only
    final branchCheckboxes = find.byType(CheckboxListTile);
    expect(
      tester.widget<CheckboxListTile>(branchCheckboxes.first).value,
      isTrue,
    );
    await tester.tap(branchCheckboxes.first);
    await tester.pumpAndSettle();
    expect(
      tester.widget<CheckboxListTile>(branchCheckboxes.first).value,
      isFalse,
    );

    // Verify PaymentRefundModel maps PostgreSQL column `refunded_by`
    final mappedRefund = PaymentRefundModel.fromJson(<String, dynamic>{
      'id': 'ref-1',
      'organization_id': 'org-1',
      'branch_id': 'br-1',
      'payment_id': 'pay-1',
      'member_id': 'mem-1',
      'amount_minor': 4000,
      'currency_code': 'USD',
      'refund_channel': 'manual_recorded',
      'reason': 'Partial refund',
      'refunded_by': 'actor-123',
      'created_at': '2026-11-25T10:00:00Z',
    });
    expect(mappedRefund.recordedBy, 'actor-123');
  });

  testWidgets(
    'Area G UI: QrScannerSheet rejects malformed tokens, submits valid tokens, and debounces duplicates within 2s',
    (tester) async {
      final streamCtrl = StreamController<String>(sync: true);
      addTearDown(streamCtrl.close);
      var scanCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QrScannerSheet(
              branchName: 'SCBD Flagship',
              debugTokenStream: streamCtrl.stream,
              onScanToken: (token) async {
                scanCalls += 1;
                return (
                  allowed: true,
                  message: 'Check-in approved (Alya Rahma)',
                  reasonCode: 'OK',
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Camera QR Check-In'), findsOneWidget);
      expect(find.text('Branch: SCBD Flagship'), findsOneWidget);
      expect(scanCalls, 0);

      // Malformed token never hits backend RPC
      streamCtrl.add('bad-qr');
      await tester.pump();
      await tester.pump();
      expect(scanCalls, 0);
      expect(find.text('QR_MALFORMED'), findsOneWidget);

      // Valid formatted token triggers callback and outcome banner
      streamCtrl.add('v1.dGVzdHBheWxvYWQ.dGVzdHNpZ25hdHVyZQ');
      await tester.pump();
      await tester.pump();
      expect(scanCalls, 1);
      expect(find.text('Check-in approved (Alya Rahma)'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Repeated scan of identical token within 2s is debounced
      streamCtrl.add('v1.dGVzdHBheWxvYWQ.dGVzdHNpZ25hdHVyZQ');
      await tester.pump();
      await tester.pump();
      expect(scanCalls, 1);

      // Distinct valid token triggers immediately
      streamCtrl.add('v1.b3RoZXJwYXlsb2Fk.b3RoZXJzaWduYXR1cmU');
      await tester.pump();
      await tester.pump();
      expect(scanCalls, 2);
    },
  );

  test('Phase 1: postgrest_filter_utils escapes ILIKE wildcards and quotes special PostgREST characters', () {
    expect(buildPostgrestIlikeOrFilter(const ['full_name'], '   '), isNull);
    expect(buildPostgrestIlikeOrFilter(const [], 'nadia'), isNull);

    expect(escapePostgresIlikeLiteral(r'a\b%c_d'), r'a\\b\%c\_d');
    expect(quotePostgrestValue(r'a,b(c)"d"\e'), r'"a,b(c)\"d\"\\e"');

    const cols = <String>['full_name', 'member_code', 'email', 'phone'];
    final commaFilter = buildPostgrestIlikeOrFilter(
      cols,
      'Nadia, Kusuma, RTM-1000',
    );
    expect(
      commaFilter,
      'full_name.ilike."%Nadia, Kusuma, RTM-1000%",'
      'member_code.ilike."%Nadia, Kusuma, RTM-1000%",'
      'email.ilike."%Nadia, Kusuma, RTM-1000%",'
      'phone.ilike."%Nadia, Kusuma, RTM-1000%"',
    );

    final specialFilter = buildPostgrestIlikeOrFilter(const [
      'full_name',
      'email',
    ], '(VIP) O\'Connor "test" 100%_a\\b');
    expect(
      specialFilter,
      r'full_name.ilike."%(VIP) O'
      '\''
      r'Connor \"test\" 100\\%\\_a\\\\b%",'
      r'email.ilike."%(VIP) O'
      '\''
      r'Connor \"test\" 100\\%\\_a\\\\b%"',
    );
  });

  test('Phase 1: DemoSandboxMemberRepository searches by name, code, email, phone, and special inputs', () async {
    final engine = createSeededEngine();
    engine.currentUser = DemoSandboxEngine.ownerUser;
    final repo = DemoSandboxMemberRepository(engine);
    final orgId = engine.members.values.first.organizationId;
    final branchId = engine.branches.values.first.id;

    final reg = await repo.registerMember(
      orgId: orgId,
      homeBranchId: branchId,
      memberCode: 'RTM-SPEC1',
      fullName: 'Clara Hendrawan',
      email: 'clara.hendrawan@ritma.demo',
      phone: '+62811998877',
    );
    final created = reg.when(
      success: (m) => m,
      failure: (f) => fail('Register member failed: $f'),
    );

    final byEmail = (await repo.fetchMembers(
      orgId: orgId,
      query: 'clara.hendrawan@',
    )).when(success: (l) => l, failure: (f) => fail('$f'));
    expect(byEmail.map((m) => m.id), contains(created.id));

    final byPhone = (await repo.fetchMembers(
      orgId: orgId,
      query: '811998877',
    )).when(success: (l) => l, failure: (f) => fail('$f'));
    expect(byPhone.map((m) => m.id), contains(created.id));

    final byCode = (await repo.fetchMembers(
      orgId: orgId,
      query: 'rtm-spec1',
    )).when(success: (l) => l, failure: (f) => fail('$f'));
    expect(byCode.map((m) => m.id), contains(created.id));

    final byCsvChars = (await repo.fetchMembers(
      orgId: orgId,
      query: 'Clara, (VIP), "RTM"',
    )).when(success: (l) => l, failure: (f) => fail('$f'));
    expect(byCsvChars, isEmpty);
  });

  testWidgets(
    'Phase 1: QrScannerSheet recovers from exceptions, surfaces error codes, and handles torch safely',
    (tester) async {
      final streamCtrl = StreamController<String>(sync: true);
      addTearDown(streamCtrl.close);
      var mode = 'throw';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QrScannerSheet(
              branchName: 'Senopati Boutique',
              debugTokenStream: streamCtrl.stream,
              onScanToken: (token) async {
                if (mode == 'throw') {
                  throw StateError('Simulated network glitch');
                }
                if (mode == 'expired') {
                  return (
                    allowed: false,
                    message: 'Denied: QR_EXPIRED',
                    reasonCode: 'QR_EXPIRED',
                  );
                }
                return (
                  allowed: false,
                  message: 'Denied: QR_INVALID_SIGNATURE',
                  reasonCode: 'QR_INVALID_SIGNATURE',
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Torch button tap must not throw on headless/no-flash environment
      await tester.tap(find.byTooltip('Turn on flash'));
      await tester.pump();

      // Thrown validation error resets processing spinner and displays SCAN_ERROR
      streamCtrl.add('v1.dGhyb3d0b2tlbg.c2lnbmF0dXJl');
      await tester.pump();
      await tester.pump();
      expect(find.text('Validating pass...'), findsNothing);
      expect(find.text('SCAN_ERROR'), findsOneWidget);

      // Expired QR outcome renders distinctly
      mode = 'expired';
      streamCtrl.add('v1.ZXhwaXJlZHRva2Vu.c2lnbmF0dXJl');
      await tester.pump();
      await tester.pump();
      expect(find.text('QR_EXPIRED'), findsOneWidget);
      expect(find.text('Denied: QR_EXPIRED'), findsOneWidget);

      // Invalid signature outcome renders distinctly
      mode = 'sig';
      streamCtrl.add('v1.aW52YWxpZHNpZw.c2lnbmF0dXJl');
      await tester.pump();
      await tester.pump();
      expect(find.text('QR_INVALID_SIGNATURE'), findsOneWidget);
    },
  );
}

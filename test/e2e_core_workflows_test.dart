import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/domain/auth_session_state.dart';
import 'package:ritma/features/booking/application/booking_providers.dart';
import 'package:ritma/features/booking/domain/booking_models.dart';
import 'package:ritma/features/dashboard/application/dashboard_providers.dart';
import 'package:ritma/features/facility_access/application/facility_access_providers.dart';
import 'package:ritma/features/members/application/member_providers.dart';
import 'package:ritma/features/organizations/application/organization_providers.dart';
import 'package:ritma/features/packages/application/package_providers.dart';
import 'package:ritma/features/packages/domain/package_models.dart';

void main() {
  const demoEnv = AppEnv(
    environment: AppEnvironment.dev,
    appName: 'RITMA',
    supabaseUrl: '',
    supabaseAnonKey: '',
    enableDebugLogging: false,
    enableDemoMode: true,
  );

  test('End-to-end RITMA workflows: multi-branch setup, packages, QR access, booking waitlist/refunds, attendance, and live KPIs', () async {
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

    // 1. Create a fresh multi-branch organization
    final orgRepo = container.read(organizationRepositoryProvider)!;
    final orgId = (await orgRepo.createOrganizationWithOwner(
      name: 'Apex Wellness Collective',
      slug: 'apex-wellness',
      businessType: 'hybrid',
      timezone: 'Asia/Jakarta',
      currencyCode: 'USD',
      firstBranchName: 'North Flagship',
      firstBranchCode: 'NRTH',
    )).when(success: (id) => id, failure: (_) => '');
    expect(orgId, isNotEmpty);

    await authCtrl.refreshWorkspaces();
    final session =
        container.read(authControllerProvider).asData?.value
            as AuthenticatedSession;
    container
        .read(activeWorkspaceProvider.notifier)
        .select(session.workspaces.first);

    final branchesA = await orgRepo
        .fetchBranches(orgId)
        .then((r) => r.when(success: (l) => l, failure: (_) => null)!);
    final branchA = branchesA.first;

    final branchB = (await orgRepo.createBranch(
      orgId: orgId,
      name: 'South Club',
      code: 'STH',
    )).when(success: (b) => b, failure: (_) => null)!;

    final roomA = (await orgRepo.createRoom(
      orgId: orgId,
      branchId: branchA.id,
      name: 'Reformer Loft',
      roomType: 'pilates_studio',
      defaultCapacity: 12,
    )).when(success: (r) => r, failure: (_) => null)!;

    // 2. Create Class Type and strictly separated Packages
    final pkgRepo = container.read(packageEntitlementRepositoryProvider)!;
    final classType = (await pkgRepo.createClassType(
      orgId: orgId,
      name: 'Reformer Pilates',
    )).when(success: (c) => c, failure: (_) => null)!;

    final gymPkg = (await pkgRepo.createPackage(
      orgId: orgId,
      name: 'North Open Gym',
      description: 'Branch-restricted facility access',
      packageType: PackageType.gymMembership,
      priceMinor: 7900,
      currencyCode: 'USD',
      rules: [
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.facilityAccess,
          durationDays: 30,
          branchAccessScope: BranchAccessScope.singleBranch,
          allowedBranchIds: <String>[branchA.id],
        ),
      ],
    )).when(success: (p) => p, failure: (_) => null)!;

    final studioPkg = (await pkgRepo.createPackage(
      orgId: orgId,
      name: '5-Class Studio Pack',
      description: 'Class credits only, no open gym access',
      packageType: PackageType.classPack,
      priceMinor: 12000,
      currencyCode: 'USD',
      rules: const [
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.classCredit,
          creditQuantity: 5,
          durationDays: 60,
          branchAccessScope: BranchAccessScope.allBranches,
        ),
      ],
    )).when(success: (p) => p, failure: (_) => null)!;

    final hybridPkg = (await pkgRepo.createPackage(
      orgId: orgId,
      name: 'Hybrid Club + Studio',
      description: 'Facility pass + 4 class credits',
      packageType: PackageType.hybrid,
      priceMinor: 16900,
      currencyCode: 'USD',
      rules: const [
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.facilityAccess,
          durationDays: 30,
          branchAccessScope: BranchAccessScope.allBranches,
        ),
        CreatePackageRuleInput(
          entitlementKind: EntitlementKind.classCredit,
          creditQuantity: 4,
          durationDays: 30,
          branchAccessScope: BranchAccessScope.allBranches,
        ),
      ],
    )).when(success: (p) => p, failure: (_) => null)!;

    // 3. Register 3 distinct members and assign packages
    final memberRepo = container.read(memberRepositoryProvider)!;
    final gymMember = (await memberRepo.registerMember(
      orgId: orgId,
      homeBranchId: branchA.id,
      memberCode: 'APX-1',
      fullName: 'Gym Only Member',
    )).when(success: (m) => m, failure: (_) => null)!;

    final studioMember = (await memberRepo.registerMember(
      orgId: orgId,
      homeBranchId: branchA.id,
      memberCode: 'APX-2',
      fullName: 'Studio Only Member',
    )).when(success: (m) => m, failure: (_) => null)!;

    final hybridMember = (await memberRepo.registerMember(
      orgId: orgId,
      homeBranchId: branchA.id,
      memberCode: 'APX-3',
      fullName: 'Hybrid Member',
    )).when(success: (m) => m, failure: (_) => null)!;

    await pkgRepo.assignPackageToMember(
      orgId: orgId,
      branchId: branchA.id,
      memberId: gymMember.id,
      packageId: gymPkg.id,
      paymentMethod: PaymentMethod.cardTerminal,
      idempotencyKey: 'e2e-assign-1',
    );
    await pkgRepo.assignPackageToMember(
      orgId: orgId,
      branchId: branchA.id,
      memberId: studioMember.id,
      packageId: studioPkg.id,
      paymentMethod: PaymentMethod.cash,
      idempotencyKey: 'e2e-assign-2',
    );
    await pkgRepo.assignPackageToMember(
      orgId: orgId,
      branchId: branchA.id,
      memberId: hybridMember.id,
      packageId: hybridPkg.id,
      paymentMethod: PaymentMethod.bankTransfer,
      idempotencyKey: 'e2e-assign-3',
    );

    // 4. Facility Access Engine: rotating QR, replay, cooldown, branch-scope, override
    final accessRepo = container.read(facilityAccessRepositoryProvider)!;
    final gymQr1 = (await accessRepo.issueMemberQrToken(
      orgId: orgId,
      memberId: gymMember.id,
    )).when(success: (t) => t, failure: (_) => null)!;

    final checkInOk = (await accessRepo.validateAndCheckIn(
      orgId: orgId,
      branchId: branchA.id,
      qrToken: gymQr1.token,
      idempotencyKey: 'checkin-key-1',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(checkInOk.allowed, isTrue);
    expect(checkInOk.reasonCode, 'OK');
    expect(checkInOk.visitId, isNotNull);

    // Replay same QR token with a different idempotency key is rejected
    final replayDenied = (await accessRepo.validateAndCheckIn(
      orgId: orgId,
      branchId: branchA.id,
      qrToken: gymQr1.token,
      idempotencyKey: 'checkin-key-2',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(replayDenied.allowed, isFalse);
    expect(replayDenied.reasonCode, 'QR_REPLAYED');

    // Fresh QR at Branch A immediately triggers duplicate cooldown
    final gymQr2 = (await accessRepo.issueMemberQrToken(
      orgId: orgId,
      memberId: gymMember.id,
    )).when(success: (t) => t, failure: (_) => null)!;
    final cooldownDenied = (await accessRepo.validateAndCheckIn(
      orgId: orgId,
      branchId: branchA.id,
      qrToken: gymQr2.token,
      idempotencyKey: 'checkin-key-3',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(cooldownDenied.allowed, isFalse);
    expect(cooldownDenied.reasonCode, 'DUPLICATE_COOLDOWN');

    // Single-branch member rejected at Branch B
    final gymQr3 = (await accessRepo.issueMemberQrToken(
      orgId: orgId,
      memberId: gymMember.id,
    )).when(success: (t) => t, failure: (_) => null)!;
    final branchDenied = (await accessRepo.validateAndCheckIn(
      orgId: orgId,
      branchId: branchB.id,
      qrToken: gymQr3.token,
      idempotencyKey: 'checkin-key-4',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(branchDenied.allowed, isFalse);
    expect(branchDenied.reasonCode, 'BRANCH_NOT_COVERED');

    // Studio-only member (class credits only) has NO facility access
    final studioQr = (await accessRepo.issueMemberQrToken(
      orgId: orgId,
      memberId: studioMember.id,
    )).when(success: (t) => t, failure: (_) => null)!;
    final noPassDenied = (await accessRepo.validateAndCheckIn(
      orgId: orgId,
      branchId: branchA.id,
      qrToken: studioQr.token,
      idempotencyKey: 'checkin-key-5',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(noPassDenied.allowed, isFalse);
    expect(noPassDenied.reasonCode, 'NO_FACILITY_ENTITLEMENT');

    // Manual override without reason fails validation; with reason succeeds
    final overrideNoReason = await accessRepo.manualCheckIn(
      orgId: orgId,
      branchId: branchA.id,
      memberId: studioMember.id,
      idempotencyKey: 'manual-1',
      forceOverride: true,
      reason: '   ',
    );
    expect(
      overrideNoReason.when(success: (_) => null, failure: (f) => f),
      isA<ValidationFailure>(),
    );

    final overrideOk = (await accessRepo.manualCheckIn(
      orgId: orgId,
      branchId: branchA.id,
      memberId: studioMember.id,
      idempotencyKey: 'manual-2',
      forceOverride: true,
      reason: 'Trial studio guest reception waiver',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(overrideOk.allowed, isTrue);

    await accessRepo.checkOutVisit(orgId: orgId, visitId: checkInOk.visitId!);

    // 5. Booking Engine: class credit separation, capacity, waitlist, early refund + promotion
    final bookingRepo = container.read(bookingRepositoryProvider)!;
    final now = DateTime.now().toUtc();
    final classSession = (await bookingRepo.createClassSession(
      orgId: orgId,
      branchId: branchA.id,
      roomId: roomA.id,
      classTypeId: classType.id,
      title: 'Morning Reformer Foundations',
      startsAt: now.add(const Duration(days: 1)),
      endsAt: now.add(const Duration(days: 1, hours: 1)),
      capacity: 1,
      creditCost: 1,
      cancellationCutoffAt: now.add(const Duration(hours: 20)),
      waitlistEnabled: true,
      instructorDisplayName: 'Coach Elena',
    )).when(success: (s) => s, failure: (_) => null)!;

    // Gym-only member cannot book class without class credits
    final gymBookRes = await bookingRepo.bookClassSession(
      orgId: orgId,
      sessionId: classSession.id,
      memberId: gymMember.id,
      idempotencyKey: 'book-gym-fail',
    );
    expect(
      gymBookRes.when(success: (_) => null, failure: (f) => f),
      isA<ConflictFailure>(),
    );

    // Studio-only member books -> confirmed, credits 5 -> 4
    final studioBook = (await bookingRepo.bookClassSession(
      orgId: orgId,
      sessionId: classSession.id,
      memberId: studioMember.id,
      idempotencyKey: 'book-studio-1',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(studioBook.status, BookingStatus.confirmed);

    var studioWallet = await pkgRepo
        .fetchMemberWallet(orgId: orgId, memberId: studioMember.id)
        .then((r) => r.when(success: (w) => w, failure: (_) => null)!);
    expect(studioWallet.totalClassCredits, 4);

    // Duplicate booking fails
    final dupBook = await bookingRepo.bookClassSession(
      orgId: orgId,
      sessionId: classSession.id,
      memberId: studioMember.id,
      idempotencyKey: 'book-studio-dup',
    );
    expect(
      dupBook.when(success: (_) => null, failure: (f) => f),
      isA<ConflictFailure>(),
    );

    // Hybrid member books full class -> waitlisted #1, credits stay 4
    final hybridBook = (await bookingRepo.bookClassSession(
      orgId: orgId,
      sessionId: classSession.id,
      memberId: hybridMember.id,
      idempotencyKey: 'book-hybrid-1',
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(hybridBook.status, BookingStatus.waitlisted);
    expect(hybridBook.waitlistPosition, 1);

    var hybridWallet = await pkgRepo
        .fetchMemberWallet(orgId: orgId, memberId: hybridMember.id)
        .then((r) => r.when(success: (w) => w, failure: (_) => null)!);
    expect(hybridWallet.totalClassCredits, 4);

    // Studio member cancels before cutoff -> refunded 1 credit (5) AND Hybrid promoted (4 -> 3)
    final cancelOutcome = (await bookingRepo.cancelClassBooking(
      orgId: orgId,
      bookingId: studioBook.bookingId,
    )).when(success: (o) => o, failure: (_) => null)!;
    expect(cancelOutcome.status, BookingStatus.cancelledEarly);
    expect(cancelOutcome.refundedCredits, 1);
    expect(cancelOutcome.promotedBookingId, hybridBook.bookingId);

    studioWallet = await pkgRepo
        .fetchMemberWallet(orgId: orgId, memberId: studioMember.id)
        .then((r) => r.when(success: (w) => w, failure: (_) => null)!);
    expect(studioWallet.totalClassCredits, 5);

    hybridWallet = await pkgRepo
        .fetchMemberWallet(orgId: orgId, memberId: hybridMember.id)
        .then((r) => r.when(success: (w) => w, failure: (_) => null)!);
    expect(hybridWallet.totalClassCredits, 3);

    // 6. Instructor Roster & Attendance Marking
    final roster = await bookingRepo
        .fetchSessionRoster(orgId: orgId, sessionId: classSession.id)
        .then((r) => r.when(success: (l) => l, failure: (_) => null)!);
    final promotedEntry = roster.firstWhere(
      (e) => e.bookingId == hybridBook.bookingId,
    );
    expect(promotedEntry.status, BookingStatus.confirmed);

    final attRes = await bookingRepo.markAttendance(
      orgId: orgId,
      bookingId: hybridBook.bookingId,
      attendanceStatus: AttendanceStatus.checkedIn,
    );
    expect(attRes.isSuccess, isTrue);

    final updatedRoster = await bookingRepo
        .fetchSessionRoster(orgId: orgId, sessionId: classSession.id)
        .then((r) => r.when(success: (l) => l, failure: (_) => null)!);
    expect(
      updatedRoster
          .firstWhere((e) => e.bookingId == hybridBook.bookingId)
          .attendanceStatus,
      AttendanceStatus.checkedIn,
    );

    // 7. Live Dashboard Metrics (zero fabricated numbers; derived from actual org actions)
    final metrics = await container.read(operationalMetricsProvider.future);
    expect(metrics.activeMembers, 3);
    expect(metrics.todayVisits, 2);
    expect(metrics.windowRevenueMinor, 7900 + 12000 + 16900);
    expect(metrics.classCapacityTotal, 1);
    expect(metrics.classConfirmedTotal, 1);
    expect(metrics.classOccupancyPct, 100.0);
  });
}

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ritma/core/config/app_env.dart';
import 'package:ritma/core/config/app_env_provider.dart';
import 'package:ritma/core/errors/app_failure.dart';
import 'package:ritma/core/network/supabase_provider.dart';
import 'package:ritma/features/auth/application/auth_providers.dart';
import 'package:ritma/features/auth/infrastructure/supabase_auth_repository.dart';
import 'package:ritma/features/booking/application/booking_providers.dart';
import 'package:ritma/features/booking/domain/booking_models.dart';
import 'package:ritma/features/booking/infrastructure/supabase_booking_repository.dart';
import 'package:ritma/features/dashboard/application/dashboard_providers.dart';
import 'package:ritma/features/dashboard/infrastructure/supabase_dashboard_repository.dart';
import 'package:ritma/features/facility_access/application/facility_access_providers.dart';
import 'package:ritma/features/facility_access/infrastructure/supabase_facility_access_repository.dart';
import 'package:ritma/features/members/application/member_providers.dart';
import 'package:ritma/features/members/domain/member_model.dart';
import 'package:ritma/features/members/infrastructure/supabase_member_repository.dart';
import 'package:ritma/features/operations_extras/application/operations_extras_providers.dart';
import 'package:ritma/features/operations_extras/domain/operations_extras_models.dart';
import 'package:ritma/features/operations_extras/infrastructure/supabase_operations_extras_repository.dart';
import 'package:ritma/features/organizations/application/organization_providers.dart';
import 'package:ritma/features/organizations/infrastructure/supabase_organization_repository.dart';
import 'package:ritma/features/packages/application/package_providers.dart';
import 'package:ritma/features/packages/domain/package_models.dart';
import 'package:ritma/features/packages/infrastructure/supabase_package_entitlement_repository.dart';
import 'package:ritma/features/payments/application/payment_providers.dart';
import 'package:ritma/features/payments/domain/payment_record_model.dart';
import 'package:ritma/features/payments/infrastructure/supabase_payment_repository.dart';
import 'package:ritma/features/personal_training/application/pt_providers.dart';
import 'package:ritma/features/personal_training/domain/pt_models.dart';
import 'package:ritma/features/personal_training/infrastructure/supabase_pt_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

void main() {
  final env = AppEnv.fromDartDefines();

  test(
    'Live Supabase integration across Auth, Multi-Role, Orgs, Members, Packages, QR Check-In, Booking/Waitlist/Roster, Dashboard, PT, Payments, Equipment, and Notifications',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final prevHttpOverrides = HttpOverrides.current;
      HttpOverrides.global = null;
      addTearDown(() => HttpOverrides.global = prevHttpOverrides);

      final client = sb.SupabaseClient(
        env.supabaseUrl,
        env.supabaseAnonKey,
        authOptions: sb.AuthClientOptions(
          autoRefreshToken: false,
          pkceAsyncStorage: _InMemoryGotrueAsyncStorage(),
        ),
      );
      addTearDown(() async => client.dispose());

      final container = ProviderContainer(
        overrides: [
          appEnvProvider.overrideWithValue(env),
          supabaseClientProvider.overrideWithValue(client),
        ],
      );
      addTearDown(container.dispose);

      // Verify real Supabase mode & repositories (never DemoSandboxEngine).
      expect(container.read(appModeProvider), AppMode.supabase);
      expect(
        container.read(authRepositoryProvider),
        isA<SupabaseAuthRepository>(),
      );
      expect(
        container.read(organizationRepositoryProvider),
        isA<SupabaseOrganizationRepository>(),
      );
      expect(
        container.read(memberRepositoryProvider),
        isA<SupabaseMemberRepository>(),
      );
      expect(
        container.read(packageEntitlementRepositoryProvider),
        isA<SupabasePackageEntitlementRepository>(),
      );
      expect(
        container.read(facilityAccessRepositoryProvider),
        isA<SupabaseFacilityAccessRepository>(),
      );
      expect(
        container.read(bookingRepositoryProvider),
        isA<SupabaseBookingRepository>(),
      );
      expect(
        container.read(dashboardRepositoryProvider),
        isA<SupabaseDashboardRepository>(),
      );
      expect(container.read(ptRepositoryProvider), isA<SupabasePtRepository>());
      expect(
        container.read(paymentRepositoryProvider),
        isA<SupabasePaymentRepository>(),
      );
      expect(
        container.read(operationsExtrasRepositoryProvider),
        isA<SupabaseOperationsExtrasRepository>(),
      );

      final authRepo = container.read(authRepositoryProvider)!;
      final orgRepo = container.read(organizationRepositoryProvider)!;
      final memberRepo = container.read(memberRepositoryProvider)!;
      final pkgRepo = container.read(packageEntitlementRepositoryProvider)!;
      final accessRepo = container.read(facilityAccessRepositoryProvider)!;
      final bookingRepo = container.read(bookingRepositoryProvider)!;
      final dashRepo = container.read(dashboardRepositoryProvider)!;
      final ptRepo = container.read(ptRepositoryProvider)!;
      final paymentRepo = container.read(paymentRepositoryProvider)!;
      final opsExtrasRepo = container.read(operationsExtrasRepositoryProvider)!;

      const uuid = Uuid();
      final tag = uuid.v4().substring(0, 8);
      final ownerEmail = 'owner.$tag@ritma.example';
      final staffEmail = 'staff.$tag@ritma.example';
      final password = 'RitmaTest1!$tag';

      // 1. Auth Sign-Up, Profile Fetch/Update, Sign-Out & Sign-In
      final ownerSignUp =
          (await authRepo.signUpWithEmail(
            email: ownerEmail,
            password: password,
            fullName: 'Owner $tag',
          )).when(
            success: (u) => u,
            failure: (f) => fail('Owner signUp failed: $f'),
          );

      final updatedProfile =
          (await authRepo.updateProfile(
            userId: ownerSignUp.id,
            fullName: 'Alina Owner $tag',
            phone: '+6281100001',
          )).when(
            success: (p) => p,
            failure: (f) => fail('Profile update failed: $f'),
          );
      expect(updatedProfile.fullName, 'Alina Owner $tag');

      final signOutRes = await authRepo.signOut();
      expect(signOutRes.isSuccess, isTrue);

      final ownerSignIn =
          (await authRepo.signInWithEmail(
            email: ownerEmail,
            password: password,
          )).when(
            success: (u) => u,
            failure: (f) => fail('Owner signIn failed: $f'),
          );
      expect(ownerSignIn.id, ownerSignUp.id);

      // 2. Organization, Multi-Branch & Studio Room Setup
      final orgId =
          (await orgRepo.createOrganizationWithOwner(
            name: 'Ritma Live Org $tag',
            slug: 'ritma-live-$tag',
            businessType: 'hybrid',
            timezone: 'Asia/Jakarta',
            currencyCode: 'USD',
            firstBranchName: 'Downtown HQ',
            firstBranchCode: 'DTN',
          )).when(
            success: (id) => id,
            failure: (f) => fail('Create org failed: $f'),
          );

      final branchesA = (await orgRepo.fetchBranches(orgId)).when(
        success: (b) => b,
        failure: (f) => fail('Fetch branches failed: $f'),
      );
      final branchA = branchesA.first;

      final branchB =
          (await orgRepo.createBranch(
            orgId: orgId,
            name: 'Westside Studio',
            code: 'WST',
            timezone: 'Asia/Jakarta',
          )).when(
            success: (b) => b,
            failure: (f) => fail('Create branchB failed: $f'),
          );

      final roomA =
          (await orgRepo.createRoom(
            orgId: orgId,
            branchId: branchA.id,
            name: 'Reformer Loft',
            roomType: 'pilates_studio',
            defaultCapacity: 10,
          )).when(
            success: (r) => r,
            failure: (f) => fail('Create room failed: $f'),
          );

      // 3. Multi-Role Invitation & Acceptance
      final staffInvite =
          (await orgRepo.inviteStaff(
            orgId: orgId,
            email: staffEmail,
            roleCode: 'branch_manager',
            branchId: branchB.id,
          )).when(
            success: (i) => i,
            failure: (f) => fail('Invite staff failed: $f'),
          );

      await authRepo.signOut();
      await authRepo
          .signUpWithEmail(
            email: staffEmail,
            password: password,
            fullName: 'Manager $tag',
          )
          .then(
            (r) => r.when(
              success: (u) => u,
              failure: (f) => fail('Staff signUp failed: $f'),
            ),
          );
      await authRepo
          .acceptOrganizationInvitation(staffInvite.token)
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Accept invite failed: $f'),
            ),
          );
      final staffWorkspaces = (await authRepo.fetchWorkspaces()).when(
        success: (w) => w,
        failure: (f) => fail('Staff fetchWorkspaces failed: $f'),
      );
      expect(
        staffWorkspaces.any(
          (w) =>
              w.organizationId == orgId &&
              w.roleCode == 'branch_manager' &&
              w.branchId == branchB.id,
        ),
        isTrue,
      );

      // Sign back in as Owner
      await authRepo.signOut();
      await authRepo
          .signInWithEmail(email: ownerEmail, password: password)
          .then(
            (r) => r.when(
              success: (u) => u,
              failure: (f) => fail('Re-signIn failed: $f'),
            ),
          );

      // 4. Register Members + Consent Claim giving Owner dual roles (org_owner + member)
      final gymMember =
          (await memberRepo.registerMember(
            orgId: orgId,
            homeBranchId: branchA.id,
            memberCode: 'L-GYM-$tag'.toUpperCase(),
            fullName: 'Gym Live Patron',
          )).when(
            success: (m) => m,
            failure: (f) => fail('Register gymMember failed: $f'),
          );

      final studioMember =
          (await memberRepo.registerMember(
            orgId: orgId,
            homeBranchId: branchA.id,
            memberCode: 'L-CLS-$tag'.toUpperCase(),
            fullName: 'Studio Live Patron',
          )).when(
            success: (m) => m,
            failure: (f) => fail('Register studioMember failed: $f'),
          );

      final hybridMember =
          (await memberRepo.registerMember(
            orgId: orgId,
            homeBranchId: branchA.id,
            memberCode: 'L-HYB-$tag'.toUpperCase(),
            fullName: 'Hybrid Live Patron',
            email: ownerEmail,
          )).when(
            success: (m) => m,
            failure: (f) => fail('Register hybridMember failed: $f'),
          );

      final claimToken =
          (await memberRepo.inviteMemberClaim(
            orgId: orgId,
            memberId: hybridMember.id,
            email: ownerEmail,
          )).when(
            success: (t) => t,
            failure: (f) => fail('Invite member claim failed: $f'),
          );
      await authRepo
          .claimMemberProfile(claimToken)
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Claim member failed: $f'),
            ),
          );

      final ownerWorkspaces = (await authRepo.fetchWorkspaces()).when(
        success: (w) => w,
        failure: (f) => fail('Fetch owner workspaces failed: $f'),
      );
      expect(ownerWorkspaces.any((w) => w.roleCode == 'org_owner'), isTrue);
      expect(
        ownerWorkspaces.any(
          (w) => w.roleCode == 'member' && w.memberId == hybridMember.id,
        ),
        isTrue,
      );

      // Verify search & status transition
      final foundMembers =
          (await memberRepo.fetchMembers(orgId: orgId, query: 'Gym Live')).when(
            success: (l) => l,
            failure: (f) => fail('Search members failed: $f'),
          );
      expect(foundMembers.map((m) => m.id), contains(gymMember.id));

      await memberRepo
          .setMemberStatus(
            orgId: orgId,
            memberId: gymMember.id,
            status: MemberStatus.frozen,
            reason: 'Verification test freeze',
          )
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Freeze member failed: $f'),
            ),
          );
      await memberRepo
          .setMemberStatus(
            orgId: orgId,
            memberId: gymMember.id,
            status: MemberStatus.active,
            reason: 'Restore active',
          )
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Reactivate member failed: $f'),
            ),
          );

      // 5. Packages, Entitlements, Freeze/Unfreeze & Credit Ledger
      final classType =
          (await pkgRepo.createClassType(
            orgId: orgId,
            name: 'Reformer Pilates',
          )).when(
            success: (c) => c,
            failure: (f) => fail('Create classType failed: $f'),
          );

      final gymPkg =
          (await pkgRepo.createPackage(
            orgId: orgId,
            name: 'Gym Monthly Branch A',
            description: 'Branch A floor only',
            packageType: PackageType.gymMembership,
            priceMinor: 8900,
            currencyCode: 'USD',
            rules: [
              CreatePackageRuleInput(
                entitlementKind: EntitlementKind.facilityAccess,
                durationDays: 30,
                branchAccessScope: BranchAccessScope.singleBranch,
                allowedBranchIds: <String>[branchA.id],
              ),
            ],
          )).when(
            success: (p) => p,
            failure: (f) => fail('Create gymPkg failed: $f'),
          );

      final studioPkg =
          (await pkgRepo.createPackage(
            orgId: orgId,
            name: '5-Class Pack',
            description: 'Classes only',
            packageType: PackageType.classPack,
            priceMinor: 15000,
            currencyCode: 'USD',
            rules: const [
              CreatePackageRuleInput(
                entitlementKind: EntitlementKind.classCredit,
                creditQuantity: 5,
                durationDays: 60,
                branchAccessScope: BranchAccessScope.allBranches,
              ),
            ],
          )).when(
            success: (p) => p,
            failure: (f) => fail('Create studioPkg failed: $f'),
          );

      final hybridPkg =
          (await pkgRepo.createPackage(
            orgId: orgId,
            name: 'Hybrid + PT Bundle',
            description: 'Access + Class + PT credits',
            packageType: PackageType.hybrid,
            priceMinor: 35000,
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
              CreatePackageRuleInput(
                entitlementKind: EntitlementKind.ptCredit,
                creditQuantity: 3,
                durationDays: 60,
                branchAccessScope: BranchAccessScope.allBranches,
              ),
            ],
          )).when(
            success: (p) => p,
            failure: (f) => fail('Create hybridPkg failed: $f'),
          );

      final gymSubId =
          (await pkgRepo.assignPackageToMember(
            orgId: orgId,
            branchId: branchA.id,
            memberId: gymMember.id,
            packageId: gymPkg.id,
            paymentMethod: PaymentMethod.cardTerminal,
            idempotencyKey: 'live-assign-gym-$tag',
          )).when(
            success: (id) => id,
            failure: (f) => fail('Assign gymPkg failed: $f'),
          );

      await pkgRepo
          .assignPackageToMember(
            orgId: orgId,
            branchId: branchA.id,
            memberId: studioMember.id,
            packageId: studioPkg.id,
            paymentMethod: PaymentMethod.cash,
            idempotencyKey: 'live-assign-studio-$tag',
          )
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Assign studio failed: $f'),
            ),
          );

      await pkgRepo
          .assignPackageToMember(
            orgId: orgId,
            branchId: branchA.id,
            memberId: hybridMember.id,
            packageId: hybridPkg.id,
            paymentMethod: PaymentMethod.bankTransfer,
            idempotencyKey: 'live-assign-hybrid-$tag',
          )
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Assign hybrid failed: $f'),
            ),
          );

      // Freeze + unfreeze subscription & adjust credits
      await pkgRepo
          .freezeSubscription(
            orgId: orgId,
            subscriptionId: gymSubId,
            reason: 'Trip',
          )
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Freeze sub failed: $f'),
            ),
          );
      await pkgRepo
          .unfreezeSubscription(orgId: orgId, subscriptionId: gymSubId)
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Unfreeze sub failed: $f'),
            ),
          );
      await pkgRepo
          .adjustMemberCredits(
            orgId: orgId,
            memberId: studioMember.id,
            creditType: CreditType.classCredit,
            delta: 1,
            reason: 'Welcome bonus credit',
            idempotencyKey: 'live-adj-$tag',
          )
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Adjust credits failed: $f'),
            ),
          );

      final studioWalletStart =
          (await pkgRepo.fetchMemberWallet(
            orgId: orgId,
            memberId: studioMember.id,
          )).when(
            success: (w) => w,
            failure: (f) => fail('Fetch studioWallet failed: $f'),
          );
      expect(studioWalletStart.totalClassCredits, 6);
      expect(studioWalletStart.hasActiveFacilityAccess, isFalse);

      // 6. Rotating QR Check-In, Replay, Cooldown, Branch Restriction, Override & Check-Out
      final qr1 = (await accessRepo.issueMemberQrToken(
        orgId: orgId,
        memberId: hybridMember.id,
      )).when(success: (q) => q, failure: (f) => fail('Issue QR failed: $f'));

      final checkInOk =
          (await accessRepo.validateAndCheckIn(
            orgId: orgId,
            branchId: branchA.id,
            qrToken: qr1.token,
            idempotencyKey: 'live-ci-1-$tag',
          )).when(
            success: (o) => o,
            failure: (f) => fail('QR check-in failed: $f'),
          );
      expect(checkInOk.allowed, isTrue);
      expect(checkInOk.visitId, isNotNull);

      final qrReplay =
          (await accessRepo.validateAndCheckIn(
            orgId: orgId,
            branchId: branchA.id,
            qrToken: qr1.token,
            idempotencyKey: 'live-ci-replay-$tag',
          )).when(
            success: (o) => o,
            failure: (f) => fail('QR replay check failed: $f'),
          );
      expect(qrReplay.allowed, isFalse);
      expect(qrReplay.reasonCode, 'QR_REPLAYED');

      // Cooldown check with fresh token at same branch
      final qrCooldown =
          (await accessRepo.issueMemberQrToken(
            orgId: orgId,
            memberId: hybridMember.id,
          )).when(
            success: (q) => q,
            failure: (f) => fail('Issue cooldown QR failed: $f'),
          );
      final cooldownRes =
          (await accessRepo.validateAndCheckIn(
            orgId: orgId,
            branchId: branchA.id,
            qrToken: qrCooldown.token,
            idempotencyKey: 'live-ci-cooldown-$tag',
          )).when(
            success: (o) => o,
            failure: (f) => fail('Cooldown check failed: $f'),
          );
      expect(cooldownRes.allowed, isFalse);
      expect(cooldownRes.reasonCode, 'DUPLICATE_COOLDOWN');

      // Single-branch member denied at Branch B
      final gymQrBranchB =
          (await accessRepo.issueMemberQrToken(
            orgId: orgId,
            memberId: gymMember.id,
          )).when(
            success: (q) => q,
            failure: (f) => fail('Issue gym QR failed: $f'),
          );
      final branchDenied =
          (await accessRepo.validateAndCheckIn(
            orgId: orgId,
            branchId: branchB.id,
            qrToken: gymQrBranchB.token,
            idempotencyKey: 'live-ci-branchb-$tag',
          )).when(
            success: (o) => o,
            failure: (f) => fail('Branch B deny failed: $f'),
          );
      expect(branchDenied.allowed, isFalse);
      expect(branchDenied.reasonCode, 'BRANCH_NOT_COVERED');

      final studioQr =
          (await accessRepo.issueMemberQrToken(
            orgId: orgId,
            memberId: studioMember.id,
          )).when(
            success: (q) => q,
            failure: (f) => fail('Issue studio QR failed: $f'),
          );
      final studioDenied =
          (await accessRepo.validateAndCheckIn(
            orgId: orgId,
            branchId: branchA.id,
            qrToken: studioQr.token,
            idempotencyKey: 'live-ci-nopass-$tag',
          )).when(
            success: (o) => o,
            failure: (f) => fail('Studio QR deny check failed: $f'),
          );
      expect(studioDenied.allowed, isFalse);
      expect(studioDenied.reasonCode, 'NO_FACILITY_ENTITLEMENT');

      final overrideOk =
          (await accessRepo.manualCheckIn(
            orgId: orgId,
            branchId: branchA.id,
            memberId: studioMember.id,
            idempotencyKey: 'live-override-$tag',
            forceOverride: true,
            reason: 'Live integration override verification',
          )).when(
            success: (o) => o,
            failure: (f) => fail('Override check-in failed: $f'),
          );
      expect(overrideOk.allowed, isTrue);

      await accessRepo
          .checkOutVisit(orgId: orgId, visitId: checkInOk.visitId!)
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Checkout visit failed: $f'),
            ),
          );

      final branchVisits =
          (await accessRepo.fetchBranchVisits(
            orgId: orgId,
            branchId: branchA.id,
          )).when(
            success: (v) => v,
            failure: (f) => fail('Fetch branch visits failed: $f'),
          );
      expect(branchVisits.length, greaterThanOrEqualTo(2));

      final hybridVisits =
          (await accessRepo.fetchMemberVisits(
            orgId: orgId,
            memberId: hybridMember.id,
          )).when(
            success: (v) => v,
            failure: (f) => fail('Fetch member visits failed: $f'),
          );
      expect(hybridVisits.length, 1);
      expect(hybridVisits.first.checkedOutAt, isNotNull);

      // 7. Class Booking, Separation, Waitlist, Cancel Refund, Promotion & Attendance
      final now = DateTime.now().toUtc();
      final classSession =
          (await bookingRepo.createClassSession(
            orgId: orgId,
            branchId: branchA.id,
            roomId: roomA.id,
            classTypeId: classType.id,
            title: 'Live Integration Reformer',
            startsAt: now.add(const Duration(days: 1)),
            endsAt: now.add(const Duration(days: 1, hours: 1)),
            capacity: 1,
            creditCost: 1,
            cancellationCutoffAt: now.add(const Duration(hours: 20)),
            waitlistEnabled: true,
            instructorDisplayName: 'Coach Alina',
          )).when(
            success: (s) => s,
            failure: (f) => fail('Create session failed: $f'),
          );

      final gymBookDenied = await bookingRepo.bookClassSession(
        orgId: orgId,
        sessionId: classSession.id,
        memberId: gymMember.id,
        idempotencyKey: 'live-book-gym-$tag',
      );
      expect(
        gymBookDenied.when(success: (_) => null, failure: (f) => f),
        isA<ConflictFailure>(),
      );

      final studioBook =
          (await bookingRepo.bookClassSession(
            orgId: orgId,
            sessionId: classSession.id,
            memberId: studioMember.id,
            idempotencyKey: 'live-book-studio-$tag',
          )).when(
            success: (o) => o,
            failure: (f) => fail('Book studio failed: $f'),
          );
      expect(studioBook.status, BookingStatus.confirmed);

      final hybridBook =
          (await bookingRepo.bookClassSession(
            orgId: orgId,
            sessionId: classSession.id,
            memberId: hybridMember.id,
            idempotencyKey: 'live-book-hybrid-$tag',
          )).when(
            success: (o) => o,
            failure: (f) => fail('Book hybrid failed: $f'),
          );
      expect(hybridBook.status, BookingStatus.waitlisted);
      expect(hybridBook.waitlistPosition, 1);

      final cancelOutcome =
          (await bookingRepo.cancelClassBooking(
            orgId: orgId,
            bookingId: studioBook.bookingId,
          )).when(
            success: (o) => o,
            failure: (f) => fail('Cancel booking failed: $f'),
          );
      expect(cancelOutcome.status, BookingStatus.cancelledEarly);
      expect(cancelOutcome.refundedCredits, 1);
      expect(cancelOutcome.promotedBookingId, hybridBook.bookingId);

      await bookingRepo
          .markAttendance(
            orgId: orgId,
            bookingId: hybridBook.bookingId,
            attendanceStatus: AttendanceStatus.checkedIn,
          )
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Mark attendance failed: $f'),
            ),
          );

      final roster =
          (await bookingRepo.fetchSessionRoster(
            orgId: orgId,
            sessionId: classSession.id,
          )).when(
            success: (r) => r,
            failure: (f) => fail('Fetch roster failed: $f'),
          );
      expect(
        roster
            .firstWhere((e) => e.bookingId == hybridBook.bookingId)
            .attendanceStatus,
        AttendanceStatus.checkedIn,
      );

      // 8. Live Operational Dashboard KPIs
      final metrics = (await dashRepo.fetchOperationalMetrics(orgId: orgId))
          .when(
            success: (m) => m,
            failure: (f) => fail('Fetch metrics failed: $f'),
          );
      expect(metrics.activeMembers, 3);
      expect(metrics.todayVisits, 2);
      expect(metrics.windowRevenueMinor, 8900 + 15000 + 35000);
      expect(metrics.classConfirmedTotal, 1);

      // 9. Personal Training (Trainer Profile + Availability + book_pt_session + complete_pt_session)
      final insertedTrainer = await client
          .from('trainer_profiles')
          .insert(<String, dynamic>{
            'organization_id': orgId,
            'user_id': ownerSignIn.id,
            'home_branch_id': branchA.id,
            'bio': 'Live test PT coach',
            'specialties': const <String>['Strength', 'Reformer'],
            'default_credit_cost': 1,
          })
          .select('id')
          .single();
      final trainerId = insertedTrainer['id'] as String;

      for (var d = 0; d <= 6; d++) {
        await client.from('trainer_availabilities').insert(<String, dynamic>{
          'organization_id': orgId,
          'branch_id': branchA.id,
          'trainer_id': trainerId,
          'weekday': d,
          'start_time': '06:00:00',
          'end_time': '22:00:00',
        });
      }

      final trainers = (await ptRepo.fetchTrainers(orgId: orgId)).when(
        success: (l) => l,
        failure: (f) => fail('Fetch trainers failed: $f'),
      );
      expect(trainers.map((t) => t.id), contains(trainerId));

      final avail =
          (await ptRepo.fetchTrainerAvailabilities(
            orgId: orgId,
            trainerId: trainerId,
          )).when(
            success: (l) => l,
            failure: (f) => fail('Fetch PT availabilities failed: $f'),
          );
      expect(avail.length, 7);

      final twoDaysOut = DateTime.now().toUtc().add(const Duration(days: 2));
      final ptStart = DateTime.utc(
        twoDaysOut.year,
        twoDaysOut.month,
        twoDaysOut.day,
        3,
        0,
      );
      final ptEnd = ptStart.add(const Duration(hours: 1));

      final ptBooked = (await ptRepo.bookPtSession(
        orgId: orgId,
        branchId: branchA.id,
        trainerId: trainerId,
        memberId: hybridMember.id,
        startsAt: ptStart,
        endsAt: ptEnd,
        idempotencyKey: 'live-pt-$tag',
      )).when(success: (o) => o, failure: (f) => fail('Book PT failed: $f'));
      expect(ptBooked.status, PtSessionStatus.scheduled);

      await ptRepo
          .completePtSession(
            orgId: orgId,
            ptSessionId: ptBooked.ptSessionId,
            notes: 'Live PT session verified',
          )
          .then(
            (r) => r.when(
              success: (_) {},
              failure: (f) => fail('Complete PT failed: $f'),
            ),
          );

      final ptSessions = (await ptRepo.fetchPtSessions(orgId: orgId)).when(
        success: (l) => l,
        failure: (f) => fail('Fetch PT sessions failed: $f'),
      );
      final donePt = ptSessions.firstWhere((s) => s.id == ptBooked.ptSessionId);
      expect(donePt.status, PtSessionStatus.completed);
      expect(donePt.notes, 'Live PT session verified');

      // 10. Payments Ledger
      final orgPayments = (await paymentRepo.fetchOrgPayments(orgId: orgId))
          .when(
            success: (l) => l,
            failure: (f) => fail('Fetch org payments failed: $f'),
          );
      expect(orgPayments.length, 3);
      expect(orgPayments.every((p) => p.status == PaymentStatus.paid), isTrue);

      final hybridPayments =
          (await paymentRepo.fetchMemberPayments(
            orgId: orgId,
            memberId: hybridMember.id,
          )).when(
            success: (l) => l,
            failure: (f) => fail('Fetch member payments failed: $f'),
          );
      expect(hybridPayments.length, 1);
      expect(hybridPayments.first.amountMinor, 35000);

      // 11. Equipment Operations
      final asset =
          (await opsExtrasRepo.createEquipmentAsset(
            orgId: orgId,
            branchId: branchA.id,
            assetCode: 'LIVE-EQ-$tag'.toUpperCase(),
            name: 'Live Reformer Carriage',
            category: 'Pilates',
          )).when(
            success: (a) => a,
            failure: (f) => fail('Create asset failed: $f'),
          );
      expect(asset.status, EquipmentStatus.operational);

      final ticket =
          (await opsExtrasRepo.createMaintenanceTicket(
            orgId: orgId,
            branchId: branchA.id,
            assetId: asset.id,
            summary: 'Footbar latch alignment',
            priority: TicketPriority.high,
          )).when(
            success: (t) => t,
            failure: (f) => fail('Create ticket failed: $f'),
          );

      final resolvedTicket =
          (await opsExtrasRepo.updateTicketStatus(
            orgId: orgId,
            ticketId: ticket.id,
            status: TicketStatus.resolved,
          )).when(
            success: (t) => t,
            failure: (f) => fail('Resolve ticket failed: $f'),
          );
      expect(resolvedTicket.status, TicketStatus.resolved);
      expect(resolvedTicket.resolvedAt, isNotNull);

      final servicedAsset =
          (await opsExtrasRepo.updateEquipmentStatus(
            orgId: orgId,
            assetId: asset.id,
            status: EquipmentStatus.needsService,
          )).when(
            success: (a) => a,
            failure: (f) => fail('Update asset status failed: $f'),
          );
      expect(servicedAsset.status, EquipmentStatus.needsService);

      // 12. Notifications Query (RLS)
      final notifications =
          (await opsExtrasRepo.fetchNotifications(orgId: orgId)).when(
            success: (n) => n,
            failure: (f) => fail('Fetch notifications failed: $f'),
          );
      expect(notifications, isA<List<UserNotificationModel>>());
      if (notifications.isNotEmpty) {
        await opsExtrasRepo
            .markNotificationRead(notificationId: notifications.first.id)
            .then(
              (r) => r.when(
                success: (_) {},
                failure: (f) => fail('Mark notification read failed: $f'),
              ),
            );
      }
    },
    skip: !env.hasSupabaseConfig
        ? 'Skipped: pass --dart-define=SUPABASE_URL and SUPABASE_ANON_KEY to execute live Supabase backend integration suite.'
        : null,
  );
}

class _InMemoryGotrueAsyncStorage extends sb.GotrueAsyncStorage {
  final Map<String, String> _store = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _store[key];

  @override
  Future<void> removeItem({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _store[key] = value;
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/auth/domain/auth_user.dart';
import '../../features/auth/domain/ritma_role.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../features/auth/domain/workspace_context.dart';
import '../../features/booking/domain/booking_models.dart';
import '../../features/dashboard/domain/operational_metrics_model.dart';
import '../../features/dashboard/domain/report_export_model.dart';
import '../../features/facility_access/domain/facility_access_models.dart';
import '../../features/members/domain/member_model.dart';
import '../../features/operations_extras/domain/operations_extras_models.dart';
import '../../features/organizations/domain/audit_log_model.dart';
import '../../features/organizations/domain/branch_model.dart';
import '../../features/organizations/domain/organization_invitation_result.dart';
import '../../features/organizations/domain/organization_model.dart';
import '../../features/organizations/domain/room_model.dart';
import '../../features/organizations/domain/staff_management_models.dart';
import '../../features/packages/domain/package_models.dart';
import '../../features/payments/domain/payment_record_model.dart';
import '../../features/personal_training/domain/pt_models.dart';
import '../errors/app_failure.dart';
import '../errors/error_mapper.dart';

/// Shared non-production in-memory backend simulator used ONLY when
/// `ENABLE_DEMO_MODE=true` without live Supabase credentials.
///
/// Mirrors the four separated PostgreSQL domain engines (Entitlements,
/// Facility Access, Booking, Credit Ledger) so vertical slices can be tested
/// and demonstrated end-to-end without fabricated static numbers.
class DemoSandboxEngine {
  DemoSandboxEngine() {
    _seedInitialData();
  }

  static const _uuid = Uuid();

  final StreamController<AuthUser?> authStreamController =
      StreamController<AuthUser?>.broadcast();

  AuthUser? currentUser;

  final Map<String, AuthUser> usersByEmail = <String, AuthUser>{};
  final Map<String, UserProfile> profiles = <String, UserProfile>{};
  final Map<String, List<WorkspaceContext>> workspacesByUser =
      <String, List<WorkspaceContext>>{};

  final Map<String, OrganizationModel> organizations =
      <String, OrganizationModel>{};
  final Map<String, BranchModel> branches = <String, BranchModel>{};
  final Map<String, RoomModel> rooms = <String, RoomModel>{};
  final Map<String, _PendingStaffInvite> _staffInvites =
      <String, _PendingStaffInvite>{};
  final List<_PendingStaffInvite> _staffInviteRecords = <_PendingStaffInvite>[];

  final Map<String, MemberModel> members = <String, MemberModel>{};
  final Map<String, _PendingMemberClaim> _memberClaims =
      <String, _PendingMemberClaim>{};

  final Map<String, ClassTypeModel> classTypes = <String, ClassTypeModel>{};
  final Map<String, PackageModel> packages = <String, PackageModel>{};
  final List<MemberSubscriptionModel> subscriptions =
      <MemberSubscriptionModel>[];
  final List<MemberEntitlementModel> entitlements = <MemberEntitlementModel>[];
  final List<CreditGrantModel> creditGrants = <CreditGrantModel>[];
  final List<CreditLedgerEntryModel> ledgerEntries = <CreditLedgerEntryModel>[];
  final Map<String, String> _assignIdempotency = <String, String>{};
  final Map<String, _AdjustmentRecord> _adjustmentIdempotency =
      <String, _AdjustmentRecord>{};

  final Map<String, String> _orgSigningSecrets = <String, String>{};
  final Set<String> _usedQrNonces = <String>{};
  final List<FacilityVisitModel> facilityVisits = <FacilityVisitModel>[];
  final Map<String, _CheckInReplay> _checkInIdempotency =
      <String, _CheckInReplay>{};

  final Map<String, ClassSessionModel> classSessions =
      <String, ClassSessionModel>{};
  final List<ClassBookingModel> classBookings = <ClassBookingModel>[];
  final Map<String, BookingActionOutcome> _bookingIdempotency =
      <String, BookingActionOutcome>{};
  final List<PaymentRecordModel> paymentRecords = <PaymentRecordModel>[];
  final List<PaymentRefundModel> paymentRefunds = <PaymentRefundModel>[];
  final Map<String, RefundOutcome> _refundIdempotency =
      <String, RefundOutcome>{};
  final List<AuditLogModel> auditLogs = <AuditLogModel>[];
  final Map<String, TrainerProfileModel> trainerProfiles =
      <String, TrainerProfileModel>{};
  final List<TrainerAvailabilityModel> trainerAvailabilities =
      <TrainerAvailabilityModel>[];
  final Map<String, PtSessionModel> ptSessions = <String, PtSessionModel>{};
  final Map<String, PtBookingOutcome> _ptIdempotency =
      <String, PtBookingOutcome>{};
  final Map<String, EquipmentAssetModel> equipmentAssets =
      <String, EquipmentAssetModel>{};
  final Map<String, MaintenanceTicketModel> maintenanceTickets =
      <String, MaintenanceTicketModel>{};
  final List<UserNotificationModel> userNotifications =
      <UserNotificationModel>[];

  static const String seedOrgId = '11111111-1111-1111-1111-111111111111';
  static const String seedBranchDowntownId =
      '22222222-2222-2222-2222-222222222201';
  static const String seedBranchWestsideId =
      '22222222-2222-2222-2222-222222222202';

  static const AuthUser ownerUser = AuthUser(
    id: 'demo-user-hybrid',
    email: 'owner@ritma.demo',
    fullName: 'Alina Santoso',
  );
  static const AuthUser memberUser = AuthUser(
    id: 'demo-user-member',
    email: 'member@ritma.demo',
    fullName: 'Raka Pratama',
  );
  static const AuthUser emptyUser = AuthUser(
    id: 'demo-user-new',
    email: 'new@ritma.demo',
    fullName: 'Nadia Wijaya',
  );

  void _seedInitialData() {
    usersByEmail[ownerUser.email] = ownerUser;
    usersByEmail[memberUser.email] = memberUser;
    usersByEmail[emptyUser.email] = emptyUser;

    profiles[ownerUser.id] = const UserProfile(
      userId: 'demo-user-hybrid',
      fullName: 'Alina Santoso',
      phone: '+62-812-0000-0100',
    );
    profiles[memberUser.id] = const UserProfile(
      userId: 'demo-user-member',
      fullName: 'Raka Pratama',
      phone: '+62-812-0000-0200',
    );
    profiles[emptyUser.id] = const UserProfile(
      userId: 'demo-user-new',
      fullName: 'Nadia Wijaya',
    );

    organizations[seedOrgId] = const OrganizationModel(
      id: seedOrgId,
      name: 'Ritma Flagship Club',
      slug: 'ritma-flagship',
      businessType: 'hybrid',
      timezone: 'Asia/Jakarta',
      currencyCode: 'USD',
      status: 'active',
    );

    branches[seedBranchDowntownId] = const BranchModel(
      id: seedBranchDowntownId,
      organizationId: seedOrgId,
      name: 'Downtown Studio',
      code: 'DTN',
      address: '120 Sudirman Ave',
      timezone: 'Asia/Jakarta',
    );
    branches[seedBranchWestsideId] = const BranchModel(
      id: seedBranchWestsideId,
      organizationId: seedOrgId,
      name: 'Westside Athletic',
      code: 'WST',
      address: '45 Kemang Rd',
      timezone: 'Asia/Jakarta',
    );

    rooms['33333333-3333-3333-3333-333333333301'] = const RoomModel(
      id: '33333333-3333-3333-3333-333333333301',
      organizationId: seedOrgId,
      branchId: seedBranchDowntownId,
      name: 'Reformer Lab',
      roomType: 'pilates_studio',
      defaultCapacity: 12,
    );
    rooms['33333333-3333-3333-3333-333333333302'] = const RoomModel(
      id: '33333333-3333-3333-3333-333333333302',
      organizationId: seedOrgId,
      branchId: seedBranchWestsideId,
      name: 'Performance Turf',
      roomType: 'functional',
      defaultCapacity: 20,
    );

    const reformerId = '44444444-4444-4444-4444-444444444401';
    const hiitId = '44444444-4444-4444-4444-444444444402';
    classTypes[reformerId] = const ClassTypeModel(
      id: reformerId,
      organizationId: seedOrgId,
      name: 'Reformer Pilates',
      colorToken: 'sage',
    );
    classTypes[hiitId] = const ClassTypeModel(
      id: hiitId,
      organizationId: seedOrgId,
      name: 'Kinetic Conditioning',
      colorToken: 'lime',
    );

    const pkgGymId = '55555555-5555-5555-5555-555555555501';
    const pkgPilatesId = '55555555-5555-5555-5555-555555555502';
    const pkgHybridId = '55555555-5555-5555-5555-555555555503';
    const pkgPtId = '55555555-5555-5555-5555-555555555504';

    packages[pkgGymId] = const PackageModel(
      id: pkgGymId,
      organizationId: seedOrgId,
      name: 'Open Gym Monthly (Single Branch)',
      description: 'Unlimited open-gym access at assigned branch. Does not grant studio class credits.',
      packageType: PackageType.gymMembership,
      priceMinor: 8900,
      currencyCode: 'USD',
      rules: <PackageEntitlementRuleModel>[
        PackageEntitlementRuleModel(
          id: '66666666-6666-6666-6666-666666666601',
          organizationId: seedOrgId,
          packageId: pkgGymId,
          entitlementKind: EntitlementKind.facilityAccess,
          durationDays: 30,
          branchAccessScope: BranchAccessScope.singleBranch,
        ),
      ],
    );

    packages[pkgPilatesId] = const PackageModel(
      id: pkgPilatesId,
      organizationId: seedOrgId,
      name: '10-Class Pilates Pack',
      description: '10 Reformer Pilates credits valid across all branches. Does not include gym entry.',
      packageType: PackageType.classPack,
      priceMinor: 24000,
      currencyCode: 'USD',
      rules: <PackageEntitlementRuleModel>[
        PackageEntitlementRuleModel(
          id: '66666666-6666-6666-6666-666666666602',
          organizationId: seedOrgId,
          packageId: pkgPilatesId,
          entitlementKind: EntitlementKind.classCredit,
          durationDays: 90,
          creditQuantity: 10,
          branchAccessScope: BranchAccessScope.allBranches,
          classScope: ClassScope.selectedClasses,
          allowedClassTypeIds: <String>[reformerId],
        ),
      ],
    );

    packages[pkgHybridId] = const PackageModel(
      id: pkgHybridId,
      organizationId: seedOrgId,
      name: 'Ritma All-Access Hybrid',
      description: 'All-branch open-gym entry + 8 monthly class credits.',
      packageType: PackageType.hybrid,
      priceMinor: 28900,
      currencyCode: 'USD',
      rules: <PackageEntitlementRuleModel>[
        PackageEntitlementRuleModel(
          id: '66666666-6666-6666-6666-666666666603',
          organizationId: seedOrgId,
          packageId: pkgHybridId,
          entitlementKind: EntitlementKind.facilityAccess,
          durationDays: 30,
          branchAccessScope: BranchAccessScope.allBranches,
        ),
        PackageEntitlementRuleModel(
          id: '66666666-6666-6666-6666-666666666604',
          organizationId: seedOrgId,
          packageId: pkgHybridId,
          entitlementKind: EntitlementKind.classCredit,
          durationDays: 30,
          creditQuantity: 8,
          branchAccessScope: BranchAccessScope.allBranches,
        ),
      ],
    );

    const member1Id = '99999999-9999-9999-9999-999999999901';
    const member2Id = '99999999-9999-9999-9999-999999999902';

    members[member1Id] = const MemberModel(
      id: member1Id,
      organizationId: seedOrgId,
      userId: 'demo-user-hybrid',
      homeBranchId: seedBranchDowntownId,
      memberCode: 'RTM-1001',
      fullName: 'Alina Santoso',
      email: 'owner@ritma.demo',
      phone: '+62-812-0000-0100',
      status: MemberStatus.active,
    );
    members[member2Id] = const MemberModel(
      id: member2Id,
      organizationId: seedOrgId,
      userId: 'demo-user-member',
      homeBranchId: seedBranchDowntownId,
      memberCode: 'RTM-1002',
      fullName: 'Raka Pratama',
      email: 'member@ritma.demo',
      phone: '+62-812-0000-0200',
      status: MemberStatus.active,
    );

    workspacesByUser[ownerUser.id] = <WorkspaceContext>[
      _buildWorkspace(
        orgId: seedOrgId,
        orgName: 'Ritma Flagship Club',
        role: RitmaRole.orgOwner,
      ),
      _buildWorkspace(
        orgId: seedOrgId,
        orgName: 'Ritma Flagship Club',
        branchId: seedBranchDowntownId,
        branchName: 'Downtown Studio',
        role: RitmaRole.branchManager,
      ),
      _buildWorkspace(
        orgId: seedOrgId,
        orgName: 'Ritma Flagship Club',
        branchId: seedBranchWestsideId,
        branchName: 'Westside Athletic',
        role: RitmaRole.instructor,
      ),
      _buildWorkspace(
        orgId: seedOrgId,
        orgName: 'Ritma Flagship Club',
        branchId: seedBranchDowntownId,
        branchName: 'Downtown Studio',
        role: RitmaRole.member,
        memberId: member1Id,
      ),
    ];

    workspacesByUser[memberUser.id] = <WorkspaceContext>[
      _buildWorkspace(
        orgId: seedOrgId,
        orgName: 'Ritma Flagship Club',
        branchId: seedBranchDowntownId,
        branchName: 'Downtown Studio',
        role: RitmaRole.member,
        memberId: member2Id,
      ),
    ];

    workspacesByUser[emptyUser.id] = <WorkspaceContext>[];

    final now = DateTime.now().toUtc();
    final demoStaffInvite = _PendingStaffInvite(
      invitationId: 'demo-staff-inv-1',
      token: 'DEMO-STAFF-INVITE',
      invitedEmail: 'new@ritma.demo',
      organizationId: seedOrgId,
      branchId: seedBranchDowntownId,
      role: RitmaRole.branchManager,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      status: 'pending',
    );
    _staffInvites['DEMO-STAFF-INVITE'] = demoStaffInvite;
    _staffInviteRecords.add(demoStaffInvite);
    _memberClaims['DEMO-MEMBER-CLAIM'] = const _PendingMemberClaim(
      organizationId: seedOrgId,
      memberId: member2Id,
    );

    _orgSigningSecrets[seedOrgId] = _uuid.v4();

    const s1Id = '77777777-7777-7777-7777-777777777701';
    const s2Id = '77777777-7777-7777-7777-777777777702';

    classSessions[s1Id] = ClassSessionModel(
      id: s1Id,
      organizationId: seedOrgId,
      branchId: seedBranchDowntownId,
      roomId: '33333333-3333-3333-3333-333333333301',
      classTypeId: reformerId,
      instructorUserId: ownerUser.id,
      instructorDisplayName: 'Alina Santoso',
      title: 'Morning Reformer Foundations',
      startsAt: now.add(const Duration(days: 1, hours: 2)),
      endsAt: now.add(const Duration(days: 1, hours: 3)),
      capacity: 12,
      creditCost: 1,
      cancellationCutoffAt: now.add(const Duration(hours: 14)),
    );

    classSessions[s2Id] = ClassSessionModel(
      id: s2Id,
      organizationId: seedOrgId,
      branchId: seedBranchWestsideId,
      roomId: '33333333-3333-3333-3333-333333333302',
      classTypeId: hiitId,
      instructorUserId: ownerUser.id,
      instructorDisplayName: 'Alina Santoso',
      title: 'Kinetic Conditioning 50',
      startsAt: now.add(const Duration(days: 2, hours: 4)),
      endsAt: now.add(const Duration(days: 2, hours: 5)),
      capacity: 16,
      creditCost: 1,
      cancellationCutoffAt: now.add(const Duration(days: 1, hours: 16)),
    );

    packages[pkgPtId] = const PackageModel(
      id: pkgPtId,
      organizationId: seedOrgId,
      name: '5-Session PT Pack',
      description:
          '5 private 1-on-1 Personal Training credits valid at all branches.',
      packageType: PackageType.ptPack,
      priceMinor: 32000,
      currencyCode: 'USD',
      rules: <PackageEntitlementRuleModel>[
        PackageEntitlementRuleModel(
          id: '66666666-6666-6666-6666-666666666605',
          organizationId: seedOrgId,
          packageId: pkgPtId,
          entitlementKind: EntitlementKind.ptCredit,
          durationDays: 90,
          creditQuantity: 5,
          branchAccessScope: BranchAccessScope.allBranches,
        ),
      ],
    );

    const trainer1Id = '88888888-8888-8888-8888-888888888801';
    trainerProfiles[trainer1Id] = const TrainerProfileModel(
      id: trainer1Id,
      organizationId: seedOrgId,
      userId: 'demo-user-hybrid',
      homeBranchId: seedBranchDowntownId,
      bio: 'CSCS strength & athletic conditioning specialist.',
      specialties: <String>['Strength', 'Mobility', 'Reformer'],
      defaultCreditCost: 1,
      displayName: 'Alina Santoso',
    );
    for (var day = 0; day <= 6; day++) {
      trainerAvailabilities.add(
        TrainerAvailabilityModel(
          id: '88888888-8888-8888-8888-88888888890$day',
          organizationId: seedOrgId,
          branchId: seedBranchDowntownId,
          trainerId: trainer1Id,
          weekday: day,
          startTime: '06:00:00',
          endTime: '22:00:00',
        ),
      );
    }

    const eq1Id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1';
    const eq2Id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2';
    equipmentAssets[eq1Id] = EquipmentAssetModel(
      id: eq1Id,
      organizationId: seedOrgId,
      branchId: seedBranchDowntownId,
      assetCode: 'DTN-RF-01',
      name: 'Merrithew V2 Max Reformer #1',
      category: 'Pilates Reformer',
      status: EquipmentStatus.needsService,
      lastServicedAt: now.subtract(const Duration(days: 45)),
    );
    equipmentAssets[eq2Id] = EquipmentAssetModel(
      id: eq2Id,
      organizationId: seedOrgId,
      branchId: seedBranchWestsideId,
      assetCode: 'WST-SQ-01',
      name: 'Rogue Monster Half Rack',
      category: 'Strength Rig',
      status: EquipmentStatus.operational,
      lastServicedAt: now.subtract(const Duration(days: 12)),
    );
    maintenanceTickets['bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1'] =
        MaintenanceTicketModel(
          id: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
          organizationId: seedOrgId,
          branchId: seedBranchDowntownId,
          assetId: eq1Id,
          summary: 'Carriage spring #3 tension calibration check',
          priority: TicketPriority.high,
          status: TicketStatus.open,
          createdAt: now.subtract(const Duration(hours: 6)),
        );

    userNotifications.addAll(<UserNotificationModel>[
      UserNotificationModel(
        id: 'cccccccc-cccc-cccc-cccc-ccccccccccc1',
        organizationId: seedOrgId,
        userId: ownerUser.id,
        title: 'Equipment service ticket opened',
        body: 'DTN-RF-01 flagged for spring tension calibration at Downtown Studio.',
        category: 'equipment',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      UserNotificationModel(
        id: 'cccccccc-cccc-cccc-cccc-ccccccccccc2',
        organizationId: seedOrgId,
        userId: memberUser.id,
        title: 'Welcome to Ritma Flagship Club',
        body:
            'Present your rotating QR pass in the Pass tab for gate check-in.',
        category: 'membership',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  static List<String> permissionsForRole(RitmaRole role) {
    return switch (role) {
      RitmaRole.orgOwner => const <String>[
        'org.manage',
        'branch.manage',
        'role.assign',
        'audit.read',
        'member.read',
        'member.write',
        'package.manage',
        'entitlement.read',
        'entitlement.assign',
        'credit.adjust',
        'payment.read',
        'payment.record',
        'payment.refund',
        'checkin.perform',
        'checkin.read',
        'checkin.force_override',
        'schedule.manage',
        'booking.read',
        'booking.manage',
        'attendance.mark',
        'dashboard.org.read',
        'dashboard.branch.read',
        'pt.manage',
        'equipment.manage',
      ],
      RitmaRole.orgAdmin => const <String>[
        'branch.manage',
        'role.assign',
        'audit.read',
        'member.read',
        'member.write',
        'package.manage',
        'entitlement.read',
        'entitlement.assign',
        'credit.adjust',
        'payment.read',
        'payment.record',
        'payment.refund',
        'checkin.perform',
        'checkin.read',
        'checkin.force_override',
        'schedule.manage',
        'booking.read',
        'booking.manage',
        'attendance.mark',
        'dashboard.org.read',
        'dashboard.branch.read',
        'pt.manage',
        'equipment.manage',
      ],
      RitmaRole.branchManager => const <String>[
        'role.assign',
        'audit.read',
        'member.read',
        'member.write',
        'entitlement.read',
        'entitlement.assign',
        'credit.adjust',
        'payment.read',
        'payment.record',
        'checkin.perform',
        'checkin.read',
        'checkin.force_override',
        'schedule.manage',
        'booking.read',
        'booking.manage',
        'attendance.mark',
        'dashboard.branch.read',
        'pt.manage',
        'equipment.manage',
      ],
      RitmaRole.receptionist => const <String>[
        'member.read',
        'member.write',
        'entitlement.read',
        'entitlement.assign',
        'payment.read',
        'payment.record',
        'checkin.perform',
        'checkin.read',
        'booking.read',
        'booking.manage',
        'attendance.mark',
      ],
      RitmaRole.gymStaff => const <String>[
        'member.read',
        'checkin.perform',
        'checkin.read',
        'equipment.manage',
      ],
      RitmaRole.instructor => const <String>['attendance.mark'],
      RitmaRole.personalTrainer => const <String>['pt.manage'],
      RitmaRole.member => const <String>['member.self'],
    };
  }

  WorkspaceContext _buildWorkspace({
    required String orgId,
    required String orgName,
    required RitmaRole role,
    String? branchId,
    String? branchName,
    String? memberId,
  }) {
    return WorkspaceContext(
      organizationId: orgId,
      organizationName: orgName,
      branchId: branchId,
      branchName: branchName,
      roleCode: role.code,
      roleDisplayName: role.displayName,
      roleRank: role.rank,
      memberId: memberId,
      permissions: permissionsForRole(role),
    );
  }

  AuthUser requireCurrentUser() {
    final user = currentUser;
    if (user == null) {
      throw const AppException(AppFailure.unauthorized());
    }
    return user;
  }

  List<WorkspaceContext> _staffWorkspacesFor(String userId, String orgId) {
    return (workspacesByUser[userId] ?? const <WorkspaceContext>[])
        .where((w) => w.organizationId == orgId && w.roleCode != 'member')
        .toList();
  }

  bool _hasOrgPermission(String orgId, String permission, {String? branchId}) {
    final userId = requireCurrentUser().id;
    final list = _staffWorkspacesFor(userId, orgId);
    for (final ws in list) {
      if (!ws.hasPermission(permission)) continue;
      if (branchId == null) {
        if (ws.branchId == null) return true;
      } else {
        if (ws.branchId == null || ws.branchId == branchId) return true;
      }
    }
    return false;
  }

  String _emailForUser(String userId) {
    for (final entry in usersByEmail.entries) {
      if (entry.value.id == userId) return entry.key;
    }
    return '';
  }

  int _highestRankForUser(String userId, String orgId) {
    final list = _staffWorkspacesFor(userId, orgId);
    var maxRank = 0;
    for (final w in list) {
      if (w.roleRank > maxRank) maxRank = w.roleRank;
    }
    return maxRank;
  }

  void _requirePermission(
    String orgId,
    String permission, {
    String? branchId,
    String? message,
  }) {
    requireCurrentUser();
    if (!_hasOrgPermission(orgId, permission, branchId: branchId)) {
      throw AppException(
        AppFailure.forbidden(
          message: message ?? 'Missing $permission permission.',
        ),
      );
    }
  }

  void _recordAudit(
    String orgId,
    String? branchId,
    String actorUserId,
    String action,
    String targetType,
    String? targetId, [
    Map<String, dynamic> metadata = const <String, dynamic>{},
  ]) {
    auditLogs.insert(
      0,
      AuditLogModel(
        id: _uuid.v4(),
        organizationId: orgId,
        branchId: branchId,
        actorUserId: actorUserId,
        action: action,
        targetType: targetType,
        targetId: targetId,
        metadata: metadata,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }

  String createOrganizationWithOwner({
    required String name,
    required String slug,
    required String businessType,
    required String timezone,
    required String currencyCode,
    required String firstBranchName,
    required String firstBranchCode,
  }) {
    final user = requireCurrentUser();
    final trimmedSlug = slug.trim().toLowerCase();
    if (organizations.values.any((o) => o.slug == trimmedSlug)) {
      throw const AppException(
        AppFailure.conflict(
          message: 'An organization with that slug already exists.',
          code: '23505',
        ),
      );
    }

    final orgId = _uuid.v4();
    final branchId = _uuid.v4();

    organizations[orgId] = OrganizationModel(
      id: orgId,
      name: name.trim(),
      slug: trimmedSlug,
      businessType: businessType,
      timezone: timezone,
      currencyCode: currencyCode.trim().toUpperCase(),
      status: 'active',
    );
    _orgSigningSecrets[orgId] = _uuid.v4();

    branches[branchId] = BranchModel(
      id: branchId,
      organizationId: orgId,
      name: firstBranchName.trim(),
      code: firstBranchCode.trim().toUpperCase(),
      timezone: timezone,
    );

    final list = workspacesByUser[user.id] ?? <WorkspaceContext>[];
    list.add(
      _buildWorkspace(
        orgId: orgId,
        orgName: name.trim(),
        role: RitmaRole.orgOwner,
      ),
    );
    workspacesByUser[user.id] = list;
    return orgId;
  }

  BranchModel createBranch({
    required String orgId,
    required String name,
    required String code,
    String? address,
    String? timezone,
  }) {
    requireCurrentUser();
    final normalizedCode = code.trim().toUpperCase();
    final dup = branches.values.any(
      (b) => b.organizationId == orgId && b.code == normalizedCode,
    );
    if (dup) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Branch code already exists in this organization.',
          code: '23505',
        ),
      );
    }
    final branch = BranchModel(
      id: _uuid.v4(),
      organizationId: orgId,
      name: name.trim(),
      code: normalizedCode,
      address: address?.trim().isEmpty ?? true ? null : address!.trim(),
      timezone: timezone,
    );
    branches[branch.id] = branch;
    return branch;
  }

  RoomModel createRoom({
    required String orgId,
    required String branchId,
    required String name,
    required String roomType,
    required int defaultCapacity,
  }) {
    requireCurrentUser();
    if (defaultCapacity <= 0) {
      throw const AppException(
        AppFailure.validation(message: 'Capacity must be greater than 0.'),
      );
    }
    final room = RoomModel(
      id: _uuid.v4(),
      organizationId: orgId,
      branchId: branchId,
      name: name.trim(),
      roomType: roomType.trim().isEmpty ? 'studio' : roomType.trim(),
      defaultCapacity: defaultCapacity,
    );
    rooms[room.id] = room;
    return room;
  }

  OrganizationInvitationResult inviteStaff({
    required String orgId,
    required String email,
    required String roleCode,
    String? branchId,
  }) {
    final user = requireCurrentUser();
    final role = RitmaRole.fromCode(roleCode);
    _requirePermission(orgId, 'role.assign', branchId: branchId);
    if (_highestRankForUser(user.id, orgId) < role.rank) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Cannot invite a role higher than your own rank.',
        ),
      );
    }
    final token = 'INV-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final invId = _uuid.v4();
    final now = DateTime.now().toUtc();
    final rec = _PendingStaffInvite(
      invitationId: invId,
      token: token,
      invitedEmail: email.trim().toLowerCase(),
      organizationId: orgId,
      branchId: branchId,
      role: role,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      status: 'pending',
    );
    _staffInvites[token] = rec;
    _staffInviteRecords.add(rec);
    _recordAudit(
      orgId,
      branchId,
      user.id,
      'staff.invited',
      'invitation',
      invId,
    );
    return OrganizationInvitationResult(
      invitationId: invId,
      token: token,
      invitedEmail: email.trim().toLowerCase(),
      roleCode: roleCode,
      branchId: branchId,
    );
  }

  void acceptInvitation(String token) {
    final user = requireCurrentUser();
    final invite = _staffInvites.remove(token.trim());
    if (invite == null || invite.status != 'pending') {
      throw const AppException(
        AppFailure.validation(
          message:
              'Invalid or expired invitation token (try DEMO-STAFF-INVITE).',
        ),
      );
    }
    final recIdx = _staffInviteRecords.indexWhere(
      (r) => r.invitationId == invite.invitationId,
    );
    if (recIdx >= 0) {
      _staffInviteRecords[recIdx] = invite.copyWith(status: 'accepted');
    }
    final org = organizations[invite.organizationId];
    final branch = invite.branchId != null ? branches[invite.branchId] : null;
    final list = workspacesByUser[user.id] ?? <WorkspaceContext>[];
    final candidate = _buildWorkspace(
      orgId: invite.organizationId,
      orgName: org?.name ?? 'Organization',
      branchId: invite.branchId,
      branchName: branch?.name,
      role: invite.role,
    );
    if (!list.any((w) => w.contextKey == candidate.contextKey)) {
      list.add(candidate);
    }
    workspacesByUser[user.id] = list;
    _recordAudit(
      invite.organizationId,
      invite.branchId,
      user.id,
      'staff.invitation_accepted',
      'invitation',
      invite.invitationId,
    );
  }

  String inviteMemberClaim({
    required String orgId,
    required String memberId,
    required String email,
  }) {
    requireCurrentUser();
    final token = 'CLAIM-${_uuid.v4().substring(0, 8).toUpperCase()}';
    _memberClaims[token] = _PendingMemberClaim(
      organizationId: orgId,
      memberId: memberId,
    );
    return token;
  }

  void claimMemberProfile(String token) {
    final user = requireCurrentUser();
    final claim = _memberClaims.remove(token.trim());
    if (claim == null) {
      throw const AppException(
        AppFailure.validation(
          message: 'Invalid or expired claim token (try DEMO-MEMBER-CLAIM).',
        ),
      );
    }
    final member = members[claim.memberId];
    if (member != null) {
      members[member.id] = member.copyWith(userId: user.id);
    }
    final org = organizations[claim.organizationId];
    final branch = member != null ? branches[member.homeBranchId] : null;
    final list = workspacesByUser[user.id] ?? <WorkspaceContext>[];
    final candidate = _buildWorkspace(
      orgId: claim.organizationId,
      orgName: org?.name ?? 'Organization',
      branchId: member?.homeBranchId,
      branchName: branch?.name,
      role: RitmaRole.member,
      memberId: claim.memberId,
    );
    if (!list.any((w) => w.contextKey == candidate.contextKey)) {
      list.add(candidate);
    }
    workspacesByUser[user.id] = list;
  }

  MemberModel registerMember({
    required String orgId,
    required String homeBranchId,
    required String memberCode,
    required String fullName,
    String? email,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    requireCurrentUser();
    final normalizedCode = memberCode.trim().toUpperCase();
    final dup = members.values.any(
      (m) => m.organizationId == orgId && m.memberCode == normalizedCode,
    );
    if (dup) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Member code already exists in this organization.',
          code: '23505',
        ),
      );
    }
    final created = MemberModel(
      id: _uuid.v4(),
      organizationId: orgId,
      homeBranchId: homeBranchId,
      memberCode: normalizedCode,
      fullName: fullName.trim(),
      email: email?.trim().isEmpty ?? true ? null : email!.trim(),
      phone: phone?.trim().isEmpty ?? true ? null : phone!.trim(),
      emergencyContactName: emergencyContactName?.trim().isEmpty ?? true
          ? null
          : emergencyContactName!.trim(),
      emergencyContactPhone: emergencyContactPhone?.trim().isEmpty ?? true
          ? null
          : emergencyContactPhone!.trim(),
      status: MemberStatus.active,
    );
    members[created.id] = created;
    return created;
  }

  void setMemberStatus({
    required String orgId,
    required String memberId,
    required MemberStatus status,
  }) {
    requireCurrentUser();
    final existing = members[memberId];
    if (existing == null || existing.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Member not found.'),
      );
    }
    members[memberId] = existing.copyWith(status: status);
  }

  PackageModel createPackage({
    required String orgId,
    required String name,
    required String description,
    required PackageType packageType,
    required int priceMinor,
    required String currencyCode,
    required List<CreatePackageRuleInput> rules,
  }) {
    requireCurrentUser();
    for (final r in rules) {
      if (r.branchAccessScope == BranchAccessScope.selectedBranches &&
          r.allowedBranchIds.isEmpty) {
        throw const AppException(
          AppFailure.validation(
            message: 'Select at least one branch for selected-branch access.',
          ),
        );
      }
    }
    final pkgId = _uuid.v4();
    final materializedRules = rules
        .map(
          (r) => PackageEntitlementRuleModel(
            id: _uuid.v4(),
            organizationId: orgId,
            packageId: pkgId,
            entitlementKind: r.entitlementKind,
            durationDays: r.durationDays,
            creditQuantity: r.creditQuantity,
            branchAccessScope: r.branchAccessScope,
            classScope: r.classScope,
            allowedBranchIds: r.allowedBranchIds,
            allowedClassTypeIds: r.allowedClassTypeIds,
          ),
        )
        .toList();

    final pkg = PackageModel(
      id: pkgId,
      organizationId: orgId,
      name: name.trim(),
      description: description.trim(),
      packageType: packageType,
      priceMinor: priceMinor,
      currencyCode: currencyCode,
      rules: materializedRules,
    );
    packages[pkgId] = pkg;
    return pkg;
  }

  void updatePackageDetails({
    required String orgId,
    required String packageId,
    required String name,
    String description = '',
    int? priceMinor,
    required bool isActive,
    BranchAccessScope? branchAccessScope,
    List<String>? allowedBranchIds,
  }) {
    final user = requireCurrentUser();
    _requirePermission(orgId, 'package.manage');
    final existing = packages[packageId];
    if (existing == null || existing.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Package not found.'),
      );
    }
    if (name.trim().isEmpty) {
      throw const AppException(
        AppFailure.validation(message: 'Package name cannot be empty.'),
      );
    }
    if (priceMinor != null && priceMinor < 0) {
      throw const AppException(
        AppFailure.validation(message: 'Package price cannot be negative.'),
      );
    }
    if (branchAccessScope == BranchAccessScope.selectedBranches &&
        (allowedBranchIds == null || allowedBranchIds.isEmpty)) {
      throw const AppException(
        AppFailure.validation(
          message: 'Select at least one branch for selected-branch access.',
        ),
      );
    }

    final updatedRules = existing.rules.map((r) {
      final scope = branchAccessScope ?? r.branchAccessScope;
      final branchesForRule = switch (scope) {
        BranchAccessScope.selectedBranches =>
          allowedBranchIds ?? r.allowedBranchIds,
        _ => const <String>[],
      };
      return r.copyWith(
        branchAccessScope: scope,
        allowedBranchIds: branchesForRule,
      );
    }).toList();

    packages[packageId] = existing.copyWith(
      name: name.trim(),
      description: description.trim(),
      priceMinor: priceMinor ?? existing.priceMinor,
      isActive: isActive,
      rules: updatedRules,
    );
    _recordAudit(
      orgId,
      null,
      user.id,
      'package.updated',
      'package',
      packageId,
      <String, dynamic>{'is_active': isActive},
    );
  }

  String assignPackageToMember({
    required String orgId,
    required String branchId,
    required String memberId,
    required String packageId,
    required PaymentMethod paymentMethod,
    required String idempotencyKey,
    DateTime? startsAt,
  }) {
    requireCurrentUser();
    final scopedKey = '$orgId:$idempotencyKey';
    final existingSubId = _assignIdempotency[scopedKey];
    if (existingSubId != null) {
      return existingSubId;
    }

    final member = members[memberId];
    final pkg = packages[packageId];
    if (member == null || member.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Member not found.'),
      );
    }
    if (pkg == null || pkg.organizationId != orgId || !pkg.isActive) {
      throw const AppException(
        AppFailure.notFound(message: 'Active package not found.'),
      );
    }
    for (final rule in pkg.rules) {
      if (rule.branchAccessScope == BranchAccessScope.selectedBranches &&
          rule.allowedBranchIds.isEmpty) {
        throw const AppException(
          AppFailure.validation(
            message:
                'Selected-branches package has no configured branch rules.',
          ),
        );
      }
    }

    final start = startsAt ?? DateTime.now().toUtc();
    int? maxDuration;
    for (final rule in pkg.rules) {
      if (rule.durationDays != null &&
          (maxDuration == null || rule.durationDays! > maxDuration)) {
        maxDuration = rule.durationDays;
      }
    }

    final subId = _uuid.v4();
    subscriptions.add(
      MemberSubscriptionModel(
        id: subId,
        organizationId: orgId,
        memberId: memberId,
        packageId: packageId,
        assignedBranchId: branchId,
        status: SubscriptionStatus.active,
        startsAt: start,
        endsAt: maxDuration != null
            ? start.add(Duration(days: maxDuration))
            : null,
      ),
    );
    paymentRecords.add(
      PaymentRecordModel(
        id: _uuid.v4(),
        organizationId: orgId,
        branchId: branchId,
        memberId: memberId,
        subscriptionId: subId,
        amountMinor: pkg.priceMinor,
        currencyCode: pkg.currencyCode,
        method: paymentMethod,
        status: PaymentStatus.paid,
        paidAt: DateTime.now().toUtc(),
        memberDisplayName: member.fullName,
      ),
    );

    for (final rule in pkg.rules) {
      if (rule.entitlementKind == EntitlementKind.facilityAccess ||
          rule.entitlementKind == EntitlementKind.unlimitedClass) {
        final allowedBranches =
            rule.branchAccessScope == BranchAccessScope.singleBranch
            ? <String>[branchId]
            : rule.allowedBranchIds;
        entitlements.add(
          MemberEntitlementModel(
            id: _uuid.v4(),
            organizationId: orgId,
            memberId: memberId,
            subscriptionId: subId,
            entitlementKind: rule.entitlementKind,
            branchAccessScope: rule.branchAccessScope,
            classScope: rule.classScope,
            validFrom: start,
            validUntil: start.add(Duration(days: rule.durationDays ?? 30)),
            status: EntitlementStatus.active,
            allowedBranchIds: allowedBranches,
          ),
        );
      } else {
        final creditType = rule.entitlementKind == EntitlementKind.ptCredit
            ? CreditType.ptCredit
            : CreditType.classCredit;
        final qty = rule.creditQuantity ?? 0;
        final grantId = _uuid.v4();
        final allowedBranches =
            rule.branchAccessScope == BranchAccessScope.singleBranch
            ? <String>[branchId]
            : rule.allowedBranchIds;

        creditGrants.add(
          CreditGrantModel(
            id: grantId,
            organizationId: orgId,
            memberId: memberId,
            subscriptionId: subId,
            creditType: creditType,
            branchAccessScope: rule.branchAccessScope,
            classScope: rule.classScope,
            initialAmount: qty,
            remainingAmount: qty,
            expiresAt: rule.durationDays != null
                ? start.add(Duration(days: rule.durationDays!))
                : null,
            status: CreditGrantStatus.active,
            allowedBranchIds: allowedBranches,
            allowedClassTypeIds: rule.allowedClassTypeIds,
          ),
        );

        ledgerEntries.add(
          CreditLedgerEntryModel(
            id: _uuid.v4(),
            organizationId: orgId,
            memberId: memberId,
            grantId: grantId,
            creditType: creditType,
            entryType: LedgerEntryType.grant,
            delta: qty,
            referenceType: 'subscription',
            referenceId: subId,
            reason: 'Package assigned: ${pkg.name}',
            createdAt: DateTime.now().toUtc(),
          ),
        );
      }
    }

    _assignIdempotency[scopedKey] = subId;
    return subId;
  }

  void freezeSubscription({
    required String orgId,
    required String subscriptionId,
  }) {
    requireCurrentUser();
    final idx = subscriptions.indexWhere(
      (s) => s.id == subscriptionId && s.organizationId == orgId,
    );
    if (idx < 0) {
      throw const AppException(
        AppFailure.notFound(message: 'Subscription not found.'),
      );
    }
    final sub = subscriptions[idx];
    if (sub.status != SubscriptionStatus.active) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Only active subscriptions can be frozen.',
          code: 'INVALID_STATE',
        ),
      );
    }
    final now = DateTime.now().toUtc();
    subscriptions[idx] = sub.copyWith(
      status: SubscriptionStatus.frozen,
      frozenAt: now,
    );

    for (var i = 0; i < entitlements.length; i++) {
      final ent = entitlements[i];
      if (ent.subscriptionId == subscriptionId &&
          ent.status == EntitlementStatus.active) {
        entitlements[i] = ent.copyWith(status: EntitlementStatus.frozen);
      }
    }
    for (var i = 0; i < creditGrants.length; i++) {
      final grant = creditGrants[i];
      if (grant.subscriptionId == subscriptionId &&
          grant.status == CreditGrantStatus.active) {
        creditGrants[i] = grant.copyWith(status: CreditGrantStatus.frozen);
      }
    }
  }

  void unfreezeSubscription({
    required String orgId,
    required String subscriptionId,
  }) {
    requireCurrentUser();
    final idx = subscriptions.indexWhere(
      (s) => s.id == subscriptionId && s.organizationId == orgId,
    );
    if (idx < 0) {
      throw const AppException(
        AppFailure.notFound(message: 'Subscription not found.'),
      );
    }
    final sub = subscriptions[idx];
    if (sub.status != SubscriptionStatus.frozen || sub.frozenAt == null) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Subscription is not currently frozen.',
          code: 'INVALID_STATE',
        ),
      );
    }
    final delta = DateTime.now().toUtc().difference(sub.frozenAt!);
    final positiveDelta = delta.isNegative ? Duration.zero : delta;
    subscriptions[idx] = sub.copyWith(
      status: SubscriptionStatus.active,
      frozenAt: null,
      totalFrozenSeconds: sub.totalFrozenSeconds + positiveDelta.inSeconds,
      endsAt: sub.endsAt?.add(positiveDelta),
    );

    for (var i = 0; i < entitlements.length; i++) {
      final ent = entitlements[i];
      if (ent.subscriptionId == subscriptionId &&
          ent.status == EntitlementStatus.frozen) {
        entitlements[i] = ent.copyWith(
          status: EntitlementStatus.active,
          validUntil: ent.validUntil.add(positiveDelta),
        );
      }
    }
    for (var i = 0; i < creditGrants.length; i++) {
      final grant = creditGrants[i];
      if (grant.subscriptionId == subscriptionId &&
          grant.status == CreditGrantStatus.frozen) {
        creditGrants[i] = grant.copyWith(
          status: grant.remainingAmount > 0
              ? CreditGrantStatus.active
              : CreditGrantStatus.depleted,
          expiresAt: grant.expiresAt?.add(positiveDelta),
        );
      }
    }
  }

  void adjustMemberCredits({
    required String orgId,
    required String memberId,
    required CreditType creditType,
    required int delta,
    required String reason,
    required String idempotencyKey,
    DateTime? expiresAt,
  }) {
    requireCurrentUser();
    if (delta == 0 || reason.trim().isEmpty) {
      throw const AppException(
        AppFailure.validation(
          message: 'Non-zero credit delta and reason are required.',
        ),
      );
    }
    final scopedKey = '$orgId:$idempotencyKey';
    final existing = _adjustmentIdempotency[scopedKey];
    if (existing != null) {
      if (existing.memberId != memberId ||
          existing.creditType != creditType ||
          existing.delta != delta) {
        throw const AppException(
          AppFailure.conflict(
            message: 'Idempotency key already used for a different adjustment.',
            code: 'IDEMPOTENCY_KEY_REUSED',
          ),
        );
      }
      return;
    }

    if (delta > 0) {
      final grantId = _uuid.v4();
      creditGrants.add(
        CreditGrantModel(
          id: grantId,
          organizationId: orgId,
          memberId: memberId,
          creditType: creditType,
          branchAccessScope: BranchAccessScope.allBranches,
          classScope: ClassScope.allClasses,
          initialAmount: delta,
          remainingAmount: delta,
          expiresAt: expiresAt,
          status: CreditGrantStatus.active,
        ),
      );
      ledgerEntries.add(
        CreditLedgerEntryModel(
          id: _uuid.v4(),
          organizationId: orgId,
          memberId: memberId,
          grantId: grantId,
          creditType: creditType,
          entryType: LedgerEntryType.adjustment,
          delta: delta,
          referenceType: 'manual_adjustment',
          referenceId: grantId,
          reason: reason.trim(),
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } else {
      final now = DateTime.now().toUtc();
      var toDebit = delta.abs();
      final eligibleIndices = <int>[];
      var available = 0;

      for (var i = 0; i < creditGrants.length; i++) {
        final g = creditGrants[i];
        if (g.organizationId == orgId &&
            g.memberId == memberId &&
            g.creditType == creditType &&
            g.status == CreditGrantStatus.active &&
            g.remainingAmount > 0 &&
            (g.expiresAt == null || g.expiresAt!.isAfter(now))) {
          eligibleIndices.add(i);
          available += g.remainingAmount;
        }
      }

      if (available < toDebit) {
        throw AppException(
          AppFailure.conflict(
            message:
                'Available balance ($available) is less than debit ($toDebit).',
            code: 'INSUFFICIENT_CREDITS',
          ),
        );
      }

      for (final idx in eligibleIndices) {
        if (toDebit <= 0) {
          break;
        }
        final g = creditGrants[idx];
        final take = g.remainingAmount < toDebit ? g.remainingAmount : toDebit;
        final nextRemaining = g.remainingAmount - take;
        creditGrants[idx] = g.copyWith(
          remainingAmount: nextRemaining,
          status: nextRemaining == 0
              ? CreditGrantStatus.depleted
              : CreditGrantStatus.active,
        );
        ledgerEntries.add(
          CreditLedgerEntryModel(
            id: _uuid.v4(),
            organizationId: orgId,
            memberId: memberId,
            grantId: g.id,
            creditType: creditType,
            entryType: LedgerEntryType.adjustment,
            delta: -take,
            referenceType: 'manual_adjustment',
            referenceId: g.id,
            reason: reason.trim(),
            createdAt: now,
          ),
        );
        toDebit -= take;
      }
    }

    _adjustmentIdempotency[scopedKey] = _AdjustmentRecord(
      memberId: memberId,
      creditType: creditType,
      delta: delta,
    );
  }

  // -------------------------------------------------------------------------
  // Facility Access & Rotating QR Engine
  // -------------------------------------------------------------------------

  String _b64UrlEncode(List<int> bytes) =>
      base64UrlEncode(bytes).replaceAll('=', '');

  List<int> _b64UrlDecode(String input) {
    final rem = input.length % 4;
    final padded = rem == 0 ? input : '$input${'=' * (4 - rem)}';
    return base64Url.decode(padded);
  }

  QrPassToken issueMemberQrToken({
    required String orgId,
    required String memberId,
  }) {
    requireCurrentUser();
    final member = members[memberId];
    if (member == null ||
        member.organizationId != orgId ||
        member.status == MemberStatus.archived) {
      throw const AppException(
        AppFailure.notFound(message: 'Member not found.'),
      );
    }

    final secret = _orgSigningSecrets.putIfAbsent(orgId, _uuid.v4);
    final issuedAt = DateTime.now().toUtc();
    final expiresAt = issuedAt.add(const Duration(seconds: 60));
    final issuedEpoch = issuedAt.millisecondsSinceEpoch ~/ 1000;
    final expiresEpoch = expiresAt.millisecondsSinceEpoch ~/ 1000;
    final nonce = _uuid.v4().replaceAll('-', '').substring(0, 16);

    final payload = '$orgId|$memberId|$issuedEpoch|$expiresEpoch|1|$nonce';
    final payloadB64 = _b64UrlEncode(utf8.encode(payload));
    final sigBytes = Hmac(
      sha256,
      utf8.encode(secret),
    ).convert(utf8.encode(payloadB64)).bytes;
    final token = 'v1.$payloadB64.${_b64UrlEncode(sigBytes)}';

    return QrPassToken(
      token: token,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      ttlSeconds: 60,
    );
  }

  CheckInOutcome validateAndCheckIn({
    required String orgId,
    required String branchId,
    required String qrToken,
    required String idempotencyKey,
    int cooldownMinutes = 15,
  }) {
    requireCurrentUser();
    final scopedKey = 'qr:$orgId:$idempotencyKey';
    final fingerprint = '$branchId|$qrToken';
    final replay = _checkInIdempotency[scopedKey];
    if (replay != null) {
      if (replay.fingerprint != fingerprint) {
        throw const AppException(
          AppFailure.conflict(
            message: 'Idempotency key already used for a different check-in.',
            code: 'IDEMPOTENCY_KEY_REUSED',
          ),
        );
      }
      return replay.outcome.copyWith(idempotentReplay: true);
    }

    final parts = qrToken.trim().split('.');
    if (parts.length != 3 || parts[0] != 'v1') {
      return const CheckInOutcome(allowed: false, reasonCode: 'QR_MALFORMED');
    }

    late final String tokenOrgId;
    late final String memberId;
    late final int issuedEpoch;
    late final int expiresEpoch;
    late final String nonce;
    late final List<int> sigBytes;

    try {
      final payload = utf8.decode(_b64UrlDecode(parts[1]));
      sigBytes = _b64UrlDecode(parts[2]);
      final fields = payload.split('|');
      if (fields.length != 6) {
        return const CheckInOutcome(allowed: false, reasonCode: 'QR_MALFORMED');
      }
      tokenOrgId = fields[0];
      memberId = fields[1];
      issuedEpoch = int.parse(fields[2]);
      expiresEpoch = int.parse(fields[3]);
      nonce = fields[5];
    } catch (_) {
      return const CheckInOutcome(allowed: false, reasonCode: 'QR_MALFORMED');
    }

    if (tokenOrgId != orgId) {
      return const CheckInOutcome(
        allowed: false,
        reasonCode: 'QR_ORG_MISMATCH',
      );
    }

    final secret = _orgSigningSecrets[orgId];
    if (secret == null) {
      return const CheckInOutcome(allowed: false, reasonCode: 'QR_INVALID_KEY');
    }

    final expectedSig = Hmac(
      sha256,
      utf8.encode(secret),
    ).convert(utf8.encode(parts[1])).bytes;
    if (sigBytes.length != expectedSig.length) {
      return const CheckInOutcome(
        allowed: false,
        reasonCode: 'QR_INVALID_SIGNATURE',
      );
    }
    var diff = 0;
    for (var i = 0; i < sigBytes.length; i++) {
      diff |= sigBytes[i] ^ expectedSig[i];
    }
    if (diff != 0) {
      return const CheckInOutcome(
        allowed: false,
        reasonCode: 'QR_INVALID_SIGNATURE',
      );
    }

    final now = DateTime.now().toUtc();
    final nowEpoch = now.millisecondsSinceEpoch ~/ 1000;
    if (expiresEpoch < issuedEpoch ||
        (expiresEpoch - issuedEpoch) > 65 ||
        issuedEpoch > nowEpoch + 10) {
      return const CheckInOutcome(allowed: false, reasonCode: 'QR_MALFORMED');
    }

    final member = members[memberId];
    if (member == null || member.organizationId != orgId) {
      return const CheckInOutcome(
        allowed: false,
        reasonCode: 'MEMBER_NOT_FOUND',
      );
    }

    if (nowEpoch > expiresEpoch + 10) {
      return CheckInOutcome(
        allowed: false,
        reasonCode: 'QR_TOKEN_EXPIRED',
        memberName: member.fullName,
      );
    }

    final nonceKey = '$orgId:$nonce';
    if (!_usedQrNonces.add(nonceKey)) {
      return CheckInOutcome(
        allowed: false,
        reasonCode: 'QR_REPLAYED',
        memberName: member.fullName,
      );
    }

    if (member.status == MemberStatus.frozen) {
      return CheckInOutcome(
        allowed: false,
        reasonCode: 'MEMBER_FROZEN',
        memberName: member.fullName,
      );
    }
    if (member.status != MemberStatus.active) {
      return CheckInOutcome(
        allowed: false,
        reasonCode: 'MEMBER_INACTIVE',
        memberName: member.fullName,
      );
    }

    final clampedCooldown = cooldownMinutes < 1 ? 1 : cooldownMinutes;
    final cooldownCutoff = now.subtract(Duration(minutes: clampedCooldown));
    final recentVisit = facilityVisits.any(
      (v) =>
          v.organizationId == orgId &&
          v.branchId == branchId &&
          v.memberId == memberId &&
          v.checkedInAt.isAfter(cooldownCutoff),
    );
    if (recentVisit) {
      return CheckInOutcome(
        allowed: false,
        reasonCode: 'DUPLICATE_COOLDOWN',
        memberName: member.fullName,
      );
    }

    final activeFacilityEnt = _findActiveFacilityEntitlement(
      orgId: orgId,
      branchId: branchId,
      memberId: memberId,
      now: now,
    );

    if (activeFacilityEnt == null) {
      final hasOtherBranch = entitlements.any(
        (e) =>
            e.organizationId == orgId &&
            e.memberId == memberId &&
            e.entitlementKind == EntitlementKind.facilityAccess &&
            e.status == EntitlementStatus.active &&
            !e.validFrom.isAfter(now) &&
            e.validUntil.isAfter(now),
      );
      return CheckInOutcome(
        allowed: false,
        reasonCode: hasOtherBranch
            ? 'BRANCH_NOT_COVERED'
            : 'NO_FACILITY_ENTITLEMENT',
        memberId: memberId,
        memberName: member.fullName,
      );
    }

    final visit = FacilityVisitModel(
      id: _uuid.v4(),
      organizationId: orgId,
      branchId: branchId,
      memberId: memberId,
      memberName: member.fullName,
      entitlementId: activeFacilityEnt.id,
      checkInMethod: 'qr',
      checkedInAt: now,
    );
    facilityVisits.add(visit);

    final outcome = CheckInOutcome(
      allowed: true,
      reasonCode: 'OK',
      visitId: visit.id,
      memberId: memberId,
      memberName: member.fullName,
      entitlementValidUntil: activeFacilityEnt.validUntil,
    );
    _checkInIdempotency[scopedKey] = _CheckInReplay(
      fingerprint: fingerprint,
      outcome: outcome,
    );
    return outcome;
  }

  CheckInOutcome manualCheckIn({
    required String orgId,
    required String branchId,
    required String memberId,
    required String idempotencyKey,
    bool forceOverride = false,
    String? reason,
  }) {
    requireCurrentUser();
    if (forceOverride && (reason == null || reason.trim().isEmpty)) {
      throw const AppException(
        AppFailure.validation(message: 'Override reason is required.'),
      );
    }

    final scopedKey = 'manual:$orgId:$idempotencyKey';
    final fingerprint = '$branchId|$memberId|$forceOverride';
    final replay = _checkInIdempotency[scopedKey];
    if (replay != null) {
      if (replay.fingerprint != fingerprint) {
        throw const AppException(
          AppFailure.conflict(
            message: 'Idempotency key already used for a different check-in.',
            code: 'IDEMPOTENCY_KEY_REUSED',
          ),
        );
      }
      return replay.outcome.copyWith(idempotentReplay: true);
    }

    final member = members[memberId];
    if (member == null ||
        member.organizationId != orgId ||
        member.status == MemberStatus.archived) {
      throw const AppException(
        AppFailure.notFound(message: 'Member not found.'),
      );
    }

    if (!forceOverride) {
      if (member.status == MemberStatus.frozen) {
        return CheckInOutcome(
          allowed: false,
          reasonCode: 'MEMBER_FROZEN',
          memberName: member.fullName,
        );
      }
      if (member.status != MemberStatus.active) {
        return CheckInOutcome(
          allowed: false,
          reasonCode: 'MEMBER_INACTIVE',
          memberName: member.fullName,
        );
      }
    }

    final now = DateTime.now().toUtc();
    final activeEnt = _findActiveFacilityEntitlement(
      orgId: orgId,
      branchId: branchId,
      memberId: memberId,
      now: now,
    );

    if (activeEnt == null && !forceOverride) {
      return CheckInOutcome(
        allowed: false,
        reasonCode: 'NO_FACILITY_ENTITLEMENT',
        memberId: memberId,
        memberName: member.fullName,
      );
    }

    final isOverride =
        activeEnt == null || member.status != MemberStatus.active;
    final visit = FacilityVisitModel(
      id: _uuid.v4(),
      organizationId: orgId,
      branchId: branchId,
      memberId: memberId,
      memberName: member.fullName,
      entitlementId: activeEnt?.id,
      checkInMethod: isOverride ? 'manual_override' : 'manual',
      overrideReason: isOverride ? reason?.trim() : null,
      checkedInAt: now,
    );
    facilityVisits.add(visit);

    final outcome = CheckInOutcome(
      allowed: true,
      reasonCode: 'OK',
      visitId: visit.id,
      memberId: memberId,
      memberName: member.fullName,
      entitlementValidUntil: activeEnt?.validUntil,
    );
    _checkInIdempotency[scopedKey] = _CheckInReplay(
      fingerprint: fingerprint,
      outcome: outcome,
    );
    return outcome;
  }

  void checkOutVisit({required String orgId, required String visitId}) {
    requireCurrentUser();
    final idx = facilityVisits.indexWhere(
      (v) => v.id == visitId && v.organizationId == orgId,
    );
    if (idx < 0) {
      throw const AppException(
        AppFailure.notFound(message: 'Facility visit not found.'),
      );
    }
    final visit = facilityVisits[idx];
    facilityVisits[idx] = visit.copyWith(
      checkedOutAt: visit.checkedOutAt ?? DateTime.now().toUtc(),
    );
  }

  List<CheckInMemberLookup> lookupMembersForCheckIn({
    required String orgId,
    required String query,
  }) {
    requireCurrentUser();
    final q = query.trim().toLowerCase();
    if (q.length < 2) {
      return const <CheckInMemberLookup>[];
    }
    return members.values
        .where(
          (m) =>
              m.organizationId == orgId &&
              m.status != MemberStatus.archived &&
              (m.fullName.toLowerCase().contains(q) ||
                  m.memberCode.toLowerCase().contains(q)),
        )
        .map(
          (m) => CheckInMemberLookup(
            id: m.id,
            memberCode: m.memberCode,
            fullName: m.fullName,
            homeBranchId: m.homeBranchId,
            status: m.status.name,
          ),
        )
        .toList();
  }

  MemberEntitlementModel? _findActiveFacilityEntitlement({
    required String orgId,
    required String branchId,
    required String memberId,
    required DateTime now,
  }) {
    for (final e in entitlements) {
      if (e.organizationId == orgId &&
          e.memberId == memberId &&
          e.entitlementKind == EntitlementKind.facilityAccess &&
          e.status == EntitlementStatus.active &&
          !e.validFrom.isAfter(now) &&
          e.validUntil.isAfter(now)) {
        if (e.branchAccessScope == BranchAccessScope.allBranches ||
            e.allowedBranchIds.contains(branchId)) {
          return e;
        }
      }
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // Studio Booking, Waitlist & Attendance Engine
  // -------------------------------------------------------------------------

  ClassSessionModel createClassSession({
    required String orgId,
    required String branchId,
    required String roomId,
    required String classTypeId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    required int creditCost,
    required DateTime cancellationCutoffAt,
    bool waitlistEnabled = true,
    String? instructorUserId,
    String instructorDisplayName = '',
  }) {
    requireCurrentUser();
    if (!endsAt.isAfter(startsAt) ||
        cancellationCutoffAt.isAfter(startsAt) ||
        capacity <= 0) {
      throw const AppException(
        AppFailure.validation(
          message: 'Invalid class session times or capacity.',
        ),
      );
    }
    final session = ClassSessionModel(
      id: _uuid.v4(),
      organizationId: orgId,
      branchId: branchId,
      roomId: roomId,
      classTypeId: classTypeId,
      instructorUserId: instructorUserId,
      instructorDisplayName: instructorDisplayName,
      title: title.trim(),
      startsAt: startsAt,
      endsAt: endsAt,
      capacity: capacity,
      creditCost: creditCost,
      cancellationCutoffAt: cancellationCutoffAt,
      waitlistEnabled: waitlistEnabled,
    );
    classSessions[session.id] = session;
    return session;
  }

  List<AssignableInstructor> fetchAssignableInstructors({
    required String orgId,
    String? branchId,
  }) {
    requireCurrentUser();
    final results = <String, AssignableInstructor>{};
    for (final entry in workspacesByUser.entries) {
      final userId = entry.key;
      final profile = profiles[userId];
      for (final ws in entry.value) {
        if (ws.organizationId != orgId || ws.roleCode == 'member') continue;
        if (!const {
          'instructor',
          'personal_trainer',
          'branch_manager',
          'org_admin',
          'org_owner',
        }.contains(ws.roleCode)) {
          continue;
        }
        if (branchId != null &&
            ws.branchId != null &&
            ws.branchId != branchId) {
          continue;
        }
        final current = results[userId];
        if (current == null ||
            _roleRankFor(ws.roleCode) > _roleRankFor(current.roleCode)) {
          results[userId] = AssignableInstructor(
            userId: userId,
            displayName: profile?.fullName ?? 'Staff',
            roleCode: ws.roleCode,
            roleDisplayName: ws.roleDisplayName,
          );
        }
      }
    }
    return results.values.toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
  }

  int _roleRankFor(String code) => RitmaRole.fromCode(code).rank;

  ClassSessionModel updateClassSession({
    required String orgId,
    required String sessionId,
    required String roomId,
    required String classTypeId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    required int capacity,
    required int creditCost,
    required DateTime cancellationCutoffAt,
    required bool waitlistEnabled,
    String? instructorUserId,
    required String instructorDisplayName,
  }) {
    final existing = classSessions[sessionId];
    if (existing == null || existing.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Class session not found.'),
      );
    }
    _requirePermission(orgId, 'schedule.manage', branchId: existing.branchId);
    if (!endsAt.isAfter(startsAt) ||
        cancellationCutoffAt.isAfter(startsAt) ||
        capacity < existing.confirmedCount ||
        capacity <= 0) {
      throw const AppException(
        AppFailure.validation(
          message: 'Invalid class session times or capacity below confirmed bookings.',
        ),
      );
    }
    final updated = existing.copyWith(
      roomId: roomId,
      classTypeId: classTypeId,
      instructorUserId: instructorUserId,
      instructorDisplayName: instructorDisplayName.trim(),
      title: title.trim(),
      startsAt: startsAt,
      endsAt: endsAt,
      capacity: capacity,
      creditCost: creditCost,
      cancellationCutoffAt: cancellationCutoffAt,
      waitlistEnabled: waitlistEnabled,
    );
    classSessions[sessionId] = updated;
    return updated;
  }

  BookingActionOutcome bookClassSession({
    required String orgId,
    required String sessionId,
    required String memberId,
    required String idempotencyKey,
  }) {
    requireCurrentUser();
    final scopedKey = 'book:$orgId:$idempotencyKey';
    final replay = _bookingIdempotency[scopedKey];
    if (replay != null) {
      return replay.copyWith(idempotentReplay: true);
    }

    final session = classSessions[sessionId];
    if (session == null || session.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Class session not found.'),
      );
    }
    final member = members[memberId];
    if (member == null ||
        member.organizationId != orgId ||
        member.status != MemberStatus.active) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Active member status required to book classes.',
          code: 'MEMBER_INACTIVE',
        ),
      );
    }

    final now = DateTime.now().toUtc();
    if (session.status != SessionStatus.scheduled ||
        !session.startsAt.isAfter(now)) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Class session is not open for booking.',
          code: 'SESSION_CLOSED',
        ),
      );
    }

    final alreadyBooked = classBookings.any(
      (b) =>
          b.sessionId == sessionId &&
          b.memberId == memberId &&
          (b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.waitlisted),
    );
    if (alreadyBooked) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Member already holds an active or waitlisted booking.',
          code: 'ALREADY_BOOKED',
        ),
      );
    }

    if (session.confirmedCount < session.capacity) {
      final bookingId = _uuid.v4();
      final consumed = _consumeMemberClassCredits(
        orgId: orgId,
        branchId: session.branchId,
        classTypeId: session.classTypeId,
        memberId: memberId,
        cost: session.creditCost,
        bookingId: bookingId,
        reason: 'Class booked: ${session.title}',
      );
      if (!consumed) {
        throw const AppException(
          AppFailure.conflict(
            message: 'Insufficient eligible class credits or active pass.',
            code: 'INSUFFICIENT_CREDITS',
          ),
        );
      }

      classBookings.add(
        ClassBookingModel(
          id: bookingId,
          organizationId: orgId,
          branchId: session.branchId,
          sessionId: sessionId,
          memberId: memberId,
          status: BookingStatus.confirmed,
          creditCost: session.creditCost,
          bookedAt: now,
        ),
      );
      classSessions[sessionId] = session.copyWith(
        confirmedCount: session.confirmedCount + 1,
      );

      final outcome = BookingActionOutcome(
        bookingId: bookingId,
        status: BookingStatus.confirmed,
      );
      _bookingIdempotency[scopedKey] = outcome;
      return outcome;
    } else if (session.waitlistEnabled) {
      var maxPos = 0;
      for (final b in classBookings) {
        if (b.sessionId == sessionId &&
            b.status == BookingStatus.waitlisted &&
            (b.waitlistPosition ?? 0) > maxPos) {
          maxPos = b.waitlistPosition!;
        }
      }
      final nextPos = maxPos + 1;
      final bookingId = _uuid.v4();
      classBookings.add(
        ClassBookingModel(
          id: bookingId,
          organizationId: orgId,
          branchId: session.branchId,
          sessionId: sessionId,
          memberId: memberId,
          status: BookingStatus.waitlisted,
          waitlistPosition: nextPos,
          creditCost: session.creditCost,
          bookedAt: now,
        ),
      );
      final outcome = BookingActionOutcome(
        bookingId: bookingId,
        status: BookingStatus.waitlisted,
        waitlistPosition: nextPos,
      );
      _bookingIdempotency[scopedKey] = outcome;
      return outcome;
    }

    throw const AppException(
      AppFailure.conflict(
        message: 'Class session is full.',
        code: 'CAPACITY_EXCEEDED',
      ),
    );
  }

  CancelBookingOutcome cancelClassBooking({
    required String orgId,
    required String bookingId,
    String? reason,
  }) {
    requireCurrentUser();
    final bIdx = classBookings.indexWhere(
      (b) => b.id == bookingId && b.organizationId == orgId,
    );
    if (bIdx < 0) {
      throw const AppException(
        AppFailure.notFound(message: 'Booking not found.'),
      );
    }
    final booking = classBookings[bIdx];
    final session = classSessions[booking.sessionId]!;

    if (booking.status == BookingStatus.cancelledEarly ||
        booking.status == BookingStatus.cancelledLate ||
        booking.status == BookingStatus.expiredUnpromoted) {
      return CancelBookingOutcome(
        status: booking.status,
        idempotentReplay: true,
      );
    }

    final now = DateTime.now().toUtc();
    if (booking.status == BookingStatus.waitlisted) {
      classBookings[bIdx] = booking.copyWith(
        status: BookingStatus.cancelledEarly,
        waitlistPosition: null,
        cancelledAt: now,
      );
      return const CancelBookingOutcome(status: BookingStatus.cancelledEarly);
    }

    final isEarly = !now.isAfter(session.cancellationCutoffAt);
    final newStatus = isEarly
        ? BookingStatus.cancelledEarly
        : BookingStatus.cancelledLate;

    classBookings[bIdx] = booking.copyWith(status: newStatus, cancelledAt: now);
    classSessions[session.id] = session.copyWith(
      confirmedCount: (session.confirmedCount - 1).clamp(0, session.capacity),
    );

    var refundedTotal = 0;
    if (isEarly) {
      refundedTotal = _refundBookingCredits(
        orgId: orgId,
        memberId: booking.memberId,
        bookingId: bookingId,
        reason: reason ?? 'Early class cancellation refund',
      );
    }

    String? promotedId;
    final updatedSession = classSessions[session.id]!;
    if (updatedSession.status == SessionStatus.scheduled &&
        now.isBefore(updatedSession.startsAt) &&
        updatedSession.confirmedCount < updatedSession.capacity) {
      final waitlisted =
          classBookings
              .asMap()
              .entries
              .where(
                (e) =>
                    e.value.sessionId == session.id &&
                    e.value.status == BookingStatus.waitlisted &&
                    members[e.value.memberId]?.status == MemberStatus.active,
              )
              .toList()
            ..sort((a, b) {
              final posCmp = (a.value.waitlistPosition ?? 9999).compareTo(
                b.value.waitlistPosition ?? 9999,
              );
              if (posCmp != 0) {
                return posCmp;
              }
              return a.value.bookedAt.compareTo(b.value.bookedAt);
            });

      for (final entry in waitlisted) {
        final ok = _consumeMemberClassCredits(
          orgId: orgId,
          branchId: updatedSession.branchId,
          classTypeId: updatedSession.classTypeId,
          memberId: entry.value.memberId,
          cost: updatedSession.creditCost,
          bookingId: entry.value.id,
          reason: 'Waitlist promoted: ${updatedSession.title}',
        );
        if (ok) {
          classBookings[entry.key] = entry.value.copyWith(
            status: BookingStatus.confirmed,
            waitlistPosition: null,
            creditCost: updatedSession.creditCost,
          );
          classSessions[session.id] = updatedSession.copyWith(
            confirmedCount: updatedSession.confirmedCount + 1,
          );
          promotedId = entry.value.id;
          break;
        }
      }
    }

    return CancelBookingOutcome(
      status: newStatus,
      refundedCredits: refundedTotal,
      promotedBookingId: promotedId,
    );
  }

  void cancelClassSession({
    required String orgId,
    required String sessionId,
    String? reason,
  }) {
    requireCurrentUser();
    final session = classSessions[sessionId];
    if (session == null || session.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Session not found.'),
      );
    }
    if (session.status == SessionStatus.cancelled) {
      return;
    }
    final now = DateTime.now().toUtc();
    for (var i = 0; i < classBookings.length; i++) {
      final b = classBookings[i];
      if (b.sessionId == sessionId &&
          (b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.waitlisted)) {
        if (b.status == BookingStatus.confirmed) {
          _refundBookingCredits(
            orgId: orgId,
            memberId: b.memberId,
            bookingId: b.id,
            reason: reason ?? 'Class session cancelled by studio',
          );
        }
        classBookings[i] = b.copyWith(
          status: BookingStatus.cancelledEarly,
          waitlistPosition: null,
          cancelledAt: now,
        );
      }
    }
    classSessions[sessionId] = session.copyWith(
      status: SessionStatus.cancelled,
      confirmedCount: 0,
    );
  }

  List<SessionRosterEntry> getSessionRoster({
    required String orgId,
    required String sessionId,
  }) {
    requireCurrentUser();
    final entries = <SessionRosterEntry>[];
    for (final b in classBookings) {
      if (b.organizationId == orgId &&
          b.sessionId == sessionId &&
          (b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.waitlisted)) {
        final member = members[b.memberId];
        entries.add(
          SessionRosterEntry(
            bookingId: b.id,
            memberId: b.memberId,
            memberDisplayName: member?.fullName ?? 'Member',
            memberCode: member?.memberCode ?? '—',
            status: b.status,
            attendanceStatus: b.attendanceStatus,
            waitlistPosition: b.waitlistPosition,
            bookedAt: b.bookedAt,
          ),
        );
      }
    }
    return entries;
  }

  void markClassAttendance({
    required String orgId,
    required String bookingId,
    required AttendanceStatus attendanceStatus,
  }) {
    requireCurrentUser();
    final idx = classBookings.indexWhere(
      (b) => b.id == bookingId && b.organizationId == orgId,
    );
    if (idx < 0) {
      throw const AppException(
        AppFailure.notFound(message: 'Booking not found.'),
      );
    }
    final booking = classBookings[idx];
    if (booking.status != BookingStatus.confirmed) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Only confirmed bookings can have attendance marked.',
          code: 'INVALID_STATE',
        ),
      );
    }
    classBookings[idx] = booking.copyWith(attendanceStatus: attendanceStatus);
  }

  bool _consumeMemberClassCredits({
    required String orgId,
    required String branchId,
    required String classTypeId,
    required String memberId,
    required int cost,
    required String bookingId,
    required String reason,
  }) {
    if (cost <= 0) {
      return true;
    }
    final now = DateTime.now().toUtc();
    final hasUnlimited = entitlements.any(
      (e) =>
          e.organizationId == orgId &&
          e.memberId == memberId &&
          e.entitlementKind == EntitlementKind.unlimitedClass &&
          e.status == EntitlementStatus.active &&
          !e.validFrom.isAfter(now) &&
          e.validUntil.isAfter(now) &&
          (e.branchAccessScope == BranchAccessScope.allBranches ||
              e.allowedBranchIds.contains(branchId)),
    );
    if (hasUnlimited) {
      return true;
    }

    final eligible = <int>[];
    var totalAvailable = 0;
    for (var i = 0; i < creditGrants.length; i++) {
      final g = creditGrants[i];
      if (g.organizationId == orgId &&
          g.memberId == memberId &&
          g.creditType == CreditType.classCredit &&
          g.status == CreditGrantStatus.active &&
          g.remainingAmount > 0 &&
          (g.expiresAt == null || g.expiresAt!.isAfter(now)) &&
          (g.branchAccessScope == BranchAccessScope.allBranches ||
              g.allowedBranchIds.contains(branchId)) &&
          (g.classScope == ClassScope.allClasses ||
              g.allowedClassTypeIds.contains(classTypeId))) {
        eligible.add(i);
        totalAvailable += g.remainingAmount;
      }
    }

    if (totalAvailable < cost) {
      return false;
    }

    eligible.sort((a, b) {
      final expA = creditGrants[a].expiresAt;
      final expB = creditGrants[b].expiresAt;
      if (expA == null && expB != null) {
        return 1;
      }
      if (expA != null && expB == null) {
        return -1;
      }
      if (expA != null && expB != null) {
        final cmp = expA.compareTo(expB);
        if (cmp != 0) {
          return cmp;
        }
      }
      return creditGrants[a].id.compareTo(creditGrants[b].id);
    });

    var remaining = cost;
    for (final idx in eligible) {
      if (remaining <= 0) {
        break;
      }
      final g = creditGrants[idx];
      final take = g.remainingAmount < remaining
          ? g.remainingAmount
          : remaining;
      final nextRemaining = g.remainingAmount - take;
      creditGrants[idx] = g.copyWith(
        remainingAmount: nextRemaining,
        status: nextRemaining == 0
            ? CreditGrantStatus.depleted
            : CreditGrantStatus.active,
      );
      ledgerEntries.add(
        CreditLedgerEntryModel(
          id: _uuid.v4(),
          organizationId: orgId,
          memberId: memberId,
          grantId: g.id,
          creditType: CreditType.classCredit,
          entryType: LedgerEntryType.consume,
          delta: -take,
          referenceType: 'class_booking',
          referenceId: bookingId,
          reason: reason,
          createdAt: now,
        ),
      );
      remaining -= take;
    }
    return true;
  }

  int _refundBookingCredits({
    required String orgId,
    required String memberId,
    required String bookingId,
    required String reason,
  }) {
    final now = DateTime.now().toUtc();
    var totalRefunded = 0;
    final consumes = ledgerEntries
        .where(
          (l) =>
              l.organizationId == orgId &&
              l.referenceType == 'class_booking' &&
              l.referenceId == bookingId &&
              l.entryType == LedgerEntryType.consume,
        )
        .toList();

    for (final c in consumes) {
      final gIdx = creditGrants.indexWhere((g) => g.id == c.grantId);
      if (gIdx < 0) {
        continue;
      }
      final g = creditGrants[gIdx];
      final alreadyRefunded = ledgerEntries.any(
        (l) =>
            l.organizationId == orgId &&
            l.referenceType == 'class_booking' &&
            l.referenceId == bookingId &&
            l.grantId == g.id &&
            l.entryType == LedgerEntryType.refund,
      );
      if (!alreadyRefunded &&
          (g.status == CreditGrantStatus.active ||
              g.status == CreditGrantStatus.depleted) &&
          (g.expiresAt == null || g.expiresAt!.isAfter(now))) {
        final refundQty = c.delta.abs();
        creditGrants[gIdx] = g.copyWith(
          remainingAmount: g.remainingAmount + refundQty,
          status: CreditGrantStatus.active,
        );
        ledgerEntries.add(
          CreditLedgerEntryModel(
            id: _uuid.v4(),
            organizationId: orgId,
            memberId: memberId,
            grantId: g.id,
            creditType: CreditType.classCredit,
            entryType: LedgerEntryType.refund,
            delta: refundQty,
            referenceType: 'class_booking',
            referenceId: bookingId,
            reason: reason,
            createdAt: now,
          ),
        );
        totalRefunded += refundQty;
      }
    }
    return totalRefunded;
  }

  // -------------------------------------------------------------------------
  // Live Operational Dashboard Metrics
  // -------------------------------------------------------------------------

  OperationalMetricsModel getOperationalDashboardMetrics({
    required String orgId,
    String? branchId,
    int windowDays = 30,
  }) {
    requireCurrentUser();
    final now = DateTime.now().toUtc();
    final todayStart = DateTime.utc(now.year, now.month, now.day);
    final windowStart = now.subtract(Duration(days: windowDays));

    final activeMembersCount = members.values
        .where(
          (m) =>
              m.organizationId == orgId &&
              m.status == MemberStatus.active &&
              (branchId == null || m.homeBranchId == branchId),
        )
        .length;

    final todayVisitsCount = facilityVisits
        .where(
          (v) =>
              v.organizationId == orgId &&
              (branchId == null || v.branchId == branchId) &&
              !v.checkedInAt.isBefore(todayStart),
        )
        .length;

    final revenueMinor = paymentRecords
        .where(
          (p) =>
              p.organizationId == orgId &&
              (branchId == null || p.branchId == branchId) &&
              (p.status == PaymentStatus.paid ||
                  p.status == PaymentStatus.refunded) &&
              !p.paidAt.isBefore(windowStart),
        )
        .fold<int>(0, (sum, p) => sum + p.netAmountMinor);

    var capTotal = 0;
    var confTotal = 0;
    for (final s in classSessions.values) {
      if (s.organizationId == orgId &&
          (branchId == null || s.branchId == branchId) &&
          s.status != SessionStatus.cancelled &&
          !s.startsAt.isBefore(windowStart) &&
          !s.startsAt.isAfter(now.add(const Duration(days: 7)))) {
        capTotal += s.capacity;
        confTotal += s.confirmedCount;
      }
    }

    final occPct = capTotal > 0
        ? double.parse(((confTotal / capTotal) * 100).toStringAsFixed(1))
        : 0.0;

    final expiring7d = entitlements.where((e) {
      if (e.organizationId != orgId || e.status != EntitlementStatus.active) {
        return false;
      }
      if (branchId != null && members[e.memberId]?.homeBranchId != branchId) {
        return false;
      }
      return e.validUntil.isAfter(now) &&
          !e.validUntil.isAfter(now.add(const Duration(days: 7)));
    }).length;

    return OperationalMetricsModel(
      activeMembers: activeMembersCount,
      todayVisits: todayVisitsCount,
      windowRevenueMinor: revenueMinor,
      classCapacityTotal: capTotal,
      classConfirmedTotal: confTotal,
      classOccupancyPct: occPct,
      expiringEntitlements7d: expiring7d,
    );
  }

  // -------------------------------------------------------------------------
  // Personal Training, Equipment Operations & Notifications (Wave 3)
  // -------------------------------------------------------------------------

  PtBookingOutcome bookPtSession({
    required String orgId,
    required String branchId,
    required String trainerId,
    required String memberId,
    required DateTime startsAt,
    required DateTime endsAt,
    int? creditCost,
    required String idempotencyKey,
  }) {
    final user = requireCurrentUser();
    final scopedKey = 'pt:$orgId:$idempotencyKey';
    final replay = _ptIdempotency[scopedKey];
    if (replay != null) {
      return replay.copyWith(idempotentReplay: true);
    }

    final trainer = trainerProfiles[trainerId];
    if (trainer == null ||
        trainer.organizationId != orgId ||
        !trainer.isActive) {
      throw const AppException(
        AppFailure.notFound(message: 'Active trainer profile not found.'),
      );
    }
    if (branchId != trainer.homeBranchId) {
      throw const AppException(
        AppFailure.validation(
          message: 'Trainer does not operate at requested branch.',
        ),
      );
    }
    final member = members[memberId];
    final isSelf = member != null && member.userId == user.id;
    final isOpsMgr =
        _hasOrgPermission(orgId, 'schedule.manage', branchId: branchId) ||
        _hasOrgPermission(orgId, 'booking.manage', branchId: branchId);
    final isOwningTrainer =
        _hasOrgPermission(orgId, 'pt.manage', branchId: branchId) &&
        trainer.userId == user.id;
    if (!isSelf && !isOpsMgr && !isOwningTrainer) {
      throw AppException(
        AppFailure.forbidden(
          message: _hasOrgPermission(orgId, 'pt.manage', branchId: branchId)
              ? 'Personal trainers can only book sessions for themselves.'
              : 'Not authorized to book PT session.',
        ),
      );
    }
    if (member == null ||
        member.organizationId != orgId ||
        member.status != MemberStatus.active) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Active member status required for PT booking.',
          code: 'MEMBER_INACTIVE',
        ),
      );
    }
    final now = DateTime.now().toUtc();
    if (!startsAt.isAfter(now) || !endsAt.isAfter(startsAt)) {
      throw const AppException(
        AppFailure.validation(
          message: 'PT slot must be in the future with end after start.',
        ),
      );
    }

    final tzOffset = switch (branches[trainer.homeBranchId]?.timezone) {
      'Asia/Jakarta' => const Duration(hours: 7),
      _ => Duration.zero,
    };
    final localStart = startsAt.toUtc().add(tzOffset);
    final localEnd = endsAt.toUtc().add(tzOffset);
    final dow = localStart.weekday % 7;
    final startMin = localStart.hour * 60 + localStart.minute;
    final endMin = localEnd.hour * 60 + localEnd.minute;

    int parseMin(String hhmmss) {
      final parts = hhmmss.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    final sameDay =
        localStart.year == localEnd.year &&
        localStart.month == localEnd.month &&
        localStart.day == localEnd.day;
    final withinAvailability =
        sameDay &&
        trainerAvailabilities.any(
          (a) =>
              a.organizationId == orgId &&
              a.branchId == trainer.homeBranchId &&
              a.trainerId == trainerId &&
              a.weekday == dow &&
              startMin >= parseMin(a.startTime) &&
              endMin <= parseMin(a.endTime),
        );
    if (!withinAvailability) {
      throw const AppException(
        AppFailure.validation(
          message: 'Requested time is outside trainer availability.',
        ),
      );
    }

    final trainerConflict = ptSessions.values.any(
      (s) =>
          s.organizationId == orgId &&
          s.trainerId == trainerId &&
          s.status == PtSessionStatus.scheduled &&
          s.startsAt.isBefore(endsAt) &&
          s.endsAt.isAfter(startsAt),
    );
    if (trainerConflict) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Trainer already has an overlapping PT session.',
          code: 'TRAINER_CONFLICT',
        ),
      );
    }

    final memberConflict = ptSessions.values.any(
      (s) =>
          s.organizationId == orgId &&
          s.memberId == memberId &&
          s.status == PtSessionStatus.scheduled &&
          s.startsAt.isBefore(endsAt) &&
          s.endsAt.isAfter(startsAt),
    );
    if (memberConflict) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Member already has an overlapping PT session.',
          code: 'MEMBER_CONFLICT',
        ),
      );
    }

    final cost = creditCost ?? trainer.defaultCreditCost;
    if (cost <= 0) {
      throw const AppException(
        AppFailure.validation(message: 'Credit cost must be positive.'),
      );
    }

    final ptId = _uuid.v4();
    final consumed = _consumeMemberPtCredits(
      orgId: orgId,
      branchId: trainer.homeBranchId,
      memberId: memberId,
      cost: cost,
      ptSessionId: ptId,
    );
    if (!consumed) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Available PT credits less than required.',
          code: 'INSUFFICIENT_PT_CREDITS',
        ),
      );
    }

    ptSessions[ptId] = PtSessionModel(
      id: ptId,
      organizationId: orgId,
      branchId: trainer.homeBranchId,
      trainerId: trainerId,
      trainerUserId: trainer.userId,
      memberId: memberId,
      startsAt: startsAt.toUtc(),
      endsAt: endsAt.toUtc(),
      creditCost: cost,
      status: PtSessionStatus.scheduled,
      trainerDisplayName: trainer.displayName,
      memberDisplayName: member.fullName,
      memberCode: member.memberCode,
    );

    final outcome = PtBookingOutcome(
      ptSessionId: ptId,
      status: PtSessionStatus.scheduled,
      creditCost: cost,
    );
    _ptIdempotency[scopedKey] = outcome;
    return outcome;
  }

  bool _consumeMemberPtCredits({
    required String orgId,
    required String branchId,
    required String memberId,
    required int cost,
    required String ptSessionId,
  }) {
    final now = DateTime.now().toUtc();
    final eligible = <int>[];
    var totalAvailable = 0;

    for (var i = 0; i < creditGrants.length; i++) {
      final g = creditGrants[i];
      if (g.organizationId != orgId ||
          g.memberId != memberId ||
          g.creditType != CreditType.ptCredit ||
          g.status != CreditGrantStatus.active ||
          g.remainingAmount <= 0 ||
          (g.expiresAt != null && !g.expiresAt!.isAfter(now))) {
        continue;
      }
      if (g.subscriptionId != null) {
        final sub = subscriptions
            .where((s) => s.id == g.subscriptionId)
            .firstOrNull;
        if (sub?.status == SubscriptionStatus.frozen) {
          continue;
        }
      }
      if (g.branchAccessScope != BranchAccessScope.allBranches &&
          !g.allowedBranchIds.contains(branchId)) {
        continue;
      }
      eligible.add(i);
      totalAvailable += g.remainingAmount;
    }

    if (totalAvailable < cost) {
      return false;
    }

    eligible.sort((aIdx, bIdx) {
      final a = creditGrants[aIdx];
      final b = creditGrants[bIdx];
      if (a.expiresAt == null && b.expiresAt == null) return 0;
      if (a.expiresAt == null) return 1;
      if (b.expiresAt == null) return -1;
      return a.expiresAt!.compareTo(b.expiresAt!);
    });

    var remaining = cost;
    for (final idx in eligible) {
      if (remaining <= 0) break;
      final g = creditGrants[idx];
      final take = remaining < g.remainingAmount
          ? remaining
          : g.remainingAmount;
      final nextRemaining = g.remainingAmount - take;
      creditGrants[idx] = g.copyWith(
        remainingAmount: nextRemaining,
        status: nextRemaining == 0
            ? CreditGrantStatus.depleted
            : CreditGrantStatus.active,
      );
      ledgerEntries.add(
        CreditLedgerEntryModel(
          id: _uuid.v4(),
          organizationId: orgId,
          memberId: memberId,
          grantId: g.id,
          creditType: CreditType.ptCredit,
          entryType: LedgerEntryType.consume,
          delta: -take,
          referenceType: 'pt_session',
          referenceId: ptSessionId,
          reason: 'PT session booked',
          createdAt: now,
        ),
      );
      remaining -= take;
    }
    return true;
  }

  void completePtSession({
    required String orgId,
    required String ptSessionId,
    String? notes,
  }) {
    final user = requireCurrentUser();
    final pt = ptSessions[ptSessionId];
    if (pt == null || pt.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'PT session not found.'),
      );
    }
    final trainer = trainerProfiles[pt.trainerId];
    final canManageSchedule = _hasOrgPermission(
      orgId,
      'schedule.manage',
      branchId: pt.branchId,
    );
    final isOwningTrainer =
        _hasOrgPermission(orgId, 'pt.manage', branchId: pt.branchId) &&
        trainer?.userId == user.id;
    if (!canManageSchedule && !isOwningTrainer) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Personal trainers can only complete their own PT sessions.',
        ),
      );
    }
    if (pt.status != PtSessionStatus.scheduled) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Only scheduled PT sessions can be completed.',
          code: 'INVALID_STATE',
        ),
      );
    }
    ptSessions[ptSessionId] = pt.copyWith(
      status: PtSessionStatus.completed,
      notes: notes?.trim().isNotEmpty == true ? notes!.trim() : pt.notes,
    );
  }

  List<PtSessionModel> fetchPtSessions({
    required String orgId,
    String? branchId,
    String? memberId,
  }) {
    final user = requireCurrentUser();
    final isOpsMgr =
        _hasOrgPermission(orgId, 'schedule.manage', branchId: branchId) ||
        _hasOrgPermission(orgId, 'booking.read', branchId: branchId);
    final isSelfMember =
        memberId != null && members[memberId]?.userId == user.id;
    final isPtTrainer = _hasOrgPermission(
      orgId,
      'pt.manage',
      branchId: branchId,
    );
    if (memberId != null && !isSelfMember && !isOpsMgr) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Not authorized to view member PT sessions.',
        ),
      );
    }
    if (memberId == null && !isOpsMgr && !isPtTrainer) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Missing permission to view PT schedule.',
        ),
      );
    }

    return ptSessions.values
        .where((s) {
          if (s.organizationId != orgId) return false;
          if (branchId != null && s.branchId != branchId) return false;
          if (memberId != null && s.memberId != memberId) return false;
          if (memberId == null && !isOpsMgr) {
            final ownerUid = trainerProfiles[s.trainerId]?.userId;
            if (ownerUid != user.id) return false;
          }
          return true;
        })
        .map((s) {
          final m = members[s.memberId];
          final t = trainerProfiles[s.trainerId];
          return s.copyWith(
            trainerUserId: s.trainerUserId ?? t?.userId,
            trainerDisplayName: t?.displayName ?? s.trainerDisplayName,
            memberDisplayName: m?.fullName ?? s.memberDisplayName,
            memberCode: m?.memberCode ?? s.memberCode,
          );
        })
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  List<PtClientLookup> lookupMembersForPtBooking({
    required String orgId,
    required String branchId,
    String query = '',
  }) {
    final user = requireCurrentUser();
    final allowed =
        _hasOrgPermission(orgId, 'pt.manage', branchId: branchId) ||
        _hasOrgPermission(orgId, 'booking.manage', branchId: branchId) ||
        _hasOrgPermission(orgId, 'schedule.manage', branchId: branchId);
    if (!allowed) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Not authorized to look up members for PT booking.',
        ),
      );
    }
    final q = query.trim().toLowerCase();
    final now = DateTime.now().toUtc();
    return members.values
        .where((m) {
          if (m.organizationId != orgId || m.status != MemberStatus.active) {
            return false;
          }
          if (q.isEmpty) return true;
          return m.fullName.toLowerCase().contains(q) ||
              m.memberCode.toLowerCase().contains(q);
        })
        .map((m) {
          var credits = 0;
          for (final g in creditGrants) {
            if (g.organizationId != orgId ||
                g.memberId != m.id ||
                g.creditType != CreditType.ptCredit ||
                g.status != CreditGrantStatus.active ||
                g.remainingAmount <= 0) {
              continue;
            }
            if (g.expiresAt != null && !g.expiresAt!.isAfter(now)) continue;
            if (g.subscriptionId != null) {
              final sub = subscriptions
                  .where((s) => s.id == g.subscriptionId)
                  .firstOrNull;
              if (sub?.status == SubscriptionStatus.frozen) continue;
            }
            if (g.branchAccessScope != BranchAccessScope.allBranches &&
                !g.allowedBranchIds.contains(branchId)) {
              continue;
            }
            credits += g.remainingAmount;
          }
          return PtClientLookup(
            id: m.id,
            memberCode: m.memberCode,
            fullName: m.fullName,
            homeBranchId: m.homeBranchId,
            status: m.status.name,
            availablePtCredits: credits,
          );
        })
        .where((_) => user.id.isNotEmpty)
        .toList()
      ..sort((a, b) {
        final byCred = b.availablePtCredits.compareTo(a.availablePtCredits);
        return byCred != 0 ? byCred : a.fullName.compareTo(b.fullName);
      });
  }

  PtCancelOutcome cancelPtSession({
    required String orgId,
    required String ptSessionId,
    String? reason,
  }) {
    final user = requireCurrentUser();
    final pt = ptSessions[ptSessionId];
    if (pt == null || pt.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'PT session not found.'),
      );
    }
    final isSelf = members[pt.memberId]?.userId == user.id;
    final isOpsMgr =
        _hasOrgPermission(orgId, 'schedule.manage', branchId: pt.branchId) ||
        _hasOrgPermission(orgId, 'booking.manage', branchId: pt.branchId);
    final isOwningTrainer =
        _hasOrgPermission(orgId, 'pt.manage', branchId: pt.branchId) &&
        trainerProfiles[pt.trainerId]?.userId == user.id;
    if (!isSelf && !isOpsMgr && !isOwningTrainer) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Not authorized to cancel this PT session.',
        ),
      );
    }
    if (pt.status == PtSessionStatus.cancelledEarly ||
        pt.status == PtSessionStatus.cancelledLate) {
      return PtCancelOutcome(status: pt.status, idempotentReplay: true);
    }
    if (pt.status != PtSessionStatus.scheduled) {
      throw const AppException(
        AppFailure.conflict(
          message: 'Only scheduled PT sessions can be cancelled.',
          code: 'INVALID_STATE',
        ),
      );
    }

    final now = DateTime.now().toUtc();
    final isEarly =
        !now.isAfter(pt.startsAt.subtract(const Duration(hours: 2))) ||
        isOpsMgr ||
        isOwningTrainer;
    final nextStatus = isEarly
        ? PtSessionStatus.cancelledEarly
        : PtSessionStatus.cancelledLate;

    final reasonClean = reason?.trim();
    ptSessions[ptSessionId] = pt.copyWith(
      status: nextStatus,
      notes: (reasonClean != null && reasonClean.isNotEmpty)
          ? (pt.notes != null && pt.notes!.trim().isNotEmpty
                ? '${pt.notes}\nCancelled: $reasonClean'
                : 'Cancelled: $reasonClean')
          : pt.notes,
    );

    var refundedTotal = 0;
    if (isEarly) {
      final consumes = ledgerEntries
          .where(
            (e) =>
                e.organizationId == orgId &&
                e.referenceType == 'pt_session' &&
                e.referenceId == ptSessionId &&
                e.entryType == LedgerEntryType.consume,
          )
          .toList();
      for (final entry in consumes) {
        final idx = creditGrants.indexWhere((g) => g.id == entry.grantId);
        if (idx < 0) continue;
        final g = creditGrants[idx];
        if ((g.status == CreditGrantStatus.active ||
                g.status == CreditGrantStatus.depleted) &&
            (g.expiresAt == null || g.expiresAt!.isAfter(now))) {
          final amt = -entry.delta;
          creditGrants[idx] = g.copyWith(
            remainingAmount: g.remainingAmount + amt,
            status: CreditGrantStatus.active,
          );
          ledgerEntries.add(
            CreditLedgerEntryModel(
              id: _uuid.v4(),
              organizationId: orgId,
              memberId: pt.memberId,
              grantId: g.id,
              creditType: CreditType.ptCredit,
              entryType: LedgerEntryType.refund,
              delta: amt,
              referenceType: 'pt_session',
              referenceId: ptSessionId,
              reason: (reasonClean != null && reasonClean.isNotEmpty)
                  ? reasonClean
                  : 'PT session cancelled refund',
              createdAt: now,
            ),
          );
          refundedTotal += amt;
        }
      }
    }
    _recordAudit(
      orgId,
      pt.branchId,
      user.id,
      'pt_session.cancelled',
      'pt_session',
      ptSessionId,
      <String, dynamic>{'refunded_credits': refundedTotal},
    );
    return PtCancelOutcome(status: nextStatus, refundedCredits: refundedTotal);
  }

  List<PaymentRefundModel> fetchPaymentRefunds({
    required String orgId,
    required String paymentId,
  }) {
    requireCurrentUser();
    return paymentRefunds
        .where((r) => r.organizationId == orgId && r.paymentId == paymentId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  RefundOutcome recordPaymentRefund({
    required String orgId,
    required String paymentId,
    required int amountMinor,
    required String reason,
    required String idempotencyKey,
    String? externalReference,
  }) {
    final user = requireCurrentUser();
    final idx = paymentRecords.indexWhere(
      (p) => p.organizationId == orgId && p.id == paymentId,
    );
    if (idx < 0) {
      throw const AppException(
        AppFailure.notFound(message: 'Payment record not found.'),
      );
    }
    final payment = paymentRecords[idx];
    _requirePermission(
      orgId,
      'payment.refund',
      branchId: payment.branchId,
      message: 'Missing payment.refund permission.',
    );

    final replayKey = '$paymentId:$idempotencyKey';
    final existingOutcome = _refundIdempotency[replayKey];
    if (existingOutcome != null) {
      return existingOutcome.copyWith(idempotentReplay: true);
    }

    if (reason.trim().isEmpty) {
      throw const AppException(
        AppFailure.validation(message: 'Refund reason is required.'),
      );
    }
    if (amountMinor <= 0) {
      throw const AppException(
        AppFailure.validation(message: 'Refund amount must be positive.'),
      );
    }
    if (payment.status != PaymentStatus.paid) {
      throw const AppException(
        AppFailure.conflict(
          message:
              'Only paid transactions with remaining balance can be refunded.',
          code: 'PAYMENT_NOT_REFUNDABLE',
        ),
      );
    }
    if (amountMinor > payment.remainingRefundableMinor) {
      throw AppException(
        AppFailure.conflict(
          message:
              'Refund ($amountMinor) exceeds remaining balance (${payment.remainingRefundableMinor}).',
          code: 'REFUND_EXCEEDS_REMAINING',
        ),
      );
    }

    final now = DateTime.now().toUtc();
    final newTotal = payment.refundedAmountMinor + amountMinor;
    final nextStatus = newTotal == payment.amountMinor
        ? PaymentStatus.refunded
        : PaymentStatus.paid;
    final refundId = _uuid.v4();
    paymentRefunds.add(
      PaymentRefundModel(
        id: refundId,
        organizationId: orgId,
        branchId: payment.branchId,
        paymentId: paymentId,
        memberId: payment.memberId,
        amountMinor: amountMinor,
        currencyCode: payment.currencyCode,
        refundChannel: 'manual_recorded',
        reason: reason.trim(),
        externalReference: externalReference?.trim().isEmpty ?? true
            ? null
            : externalReference!.trim(),
        recordedBy: user.id,
        createdAt: now,
      ),
    );
    paymentRecords[idx] = payment.copyWith(
      refundedAmountMinor: newTotal,
      refundReason: reason.trim(),
      refundedAt: now,
      status: nextStatus,
    );
    _recordAudit(
      orgId,
      payment.branchId,
      user.id,
      'payment.refund_recorded',
      'payment_record',
      paymentId,
      <String, dynamic>{
        'amount_minor': amountMinor,
        'total_refunded_minor': newTotal,
      },
    );
    final outcome = RefundOutcome(
      refundId: refundId,
      paymentId: paymentId,
      paymentStatus: nextStatus,
      amountMinor: amountMinor,
      totalRefundedMinor: newTotal,
    );
    _refundIdempotency[replayKey] = outcome;
    return outcome;
  }

  void updateOrganizationSettings({
    required String orgId,
    required String name,
    required String businessType,
    required String timezone,
    required String currencyCode,
  }) {
    final user = requireCurrentUser();
    _requirePermission(orgId, 'org.manage');
    final existing = organizations[orgId];
    if (existing == null) {
      throw const AppException(
        AppFailure.notFound(message: 'Organization not found.'),
      );
    }
    organizations[orgId] = existing.copyWith(
      name: name.trim(),
      businessType: businessType,
      timezone: timezone,
      currencyCode: currencyCode.trim().toUpperCase(),
    );
    _recordAudit(
      orgId,
      null,
      user.id,
      'organization.updated',
      'organization',
      orgId,
    );
  }

  void rotateOrgSigningKey(String orgId) {
    final user = requireCurrentUser();
    _requirePermission(orgId, 'org.manage');
    _orgSigningSecrets[orgId] = _uuid.v4();
    _recordAudit(
      orgId,
      null,
      user.id,
      'qr_signing_key.rotated',
      'organization',
      orgId,
    );
  }

  BranchModel updateBranch({
    required String orgId,
    required String branchId,
    required String name,
    required String code,
    String? address,
    String? timezone,
    required bool isActive,
  }) {
    final user = requireCurrentUser();
    _requirePermission(orgId, 'branch.manage');
    final existing = branches[branchId];
    if (existing == null || existing.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Branch not found.'),
      );
    }
    final updated = existing.copyWith(
      name: name.trim(),
      code: code.trim().toUpperCase(),
      address: address?.trim().isEmpty ?? true ? null : address!.trim(),
      timezone: timezone ?? existing.timezone,
      isActive: isActive,
    );
    branches[branchId] = updated;
    _recordAudit(
      orgId,
      branchId,
      user.id,
      'branch.updated',
      'branch',
      branchId,
    );
    return updated;
  }

  RoomModel updateRoom({
    required String orgId,
    required String roomId,
    required String name,
    required String roomType,
    required int defaultCapacity,
    required bool isActive,
  }) {
    final existing = rooms[roomId];
    if (existing == null || existing.organizationId != orgId) {
      throw const AppException(AppFailure.notFound(message: 'Room not found.'));
    }
    _requirePermission(orgId, 'branch.manage', branchId: existing.branchId);
    final updated = existing.copyWith(
      name: name.trim(),
      roomType: roomType.trim().isEmpty ? 'studio' : roomType.trim(),
      defaultCapacity: defaultCapacity,
      isActive: isActive,
    );
    rooms[roomId] = updated;
    return updated;
  }

  MemberModel updateMember({
    required String orgId,
    required String memberId,
    required String homeBranchId,
    required String fullName,
    String? email,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    final user = requireCurrentUser();
    final existing = members[memberId];
    if (existing == null || existing.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Member not found.'),
      );
    }
    _requirePermission(orgId, 'member.write', branchId: existing.homeBranchId);
    final updated = existing.copyWith(
      homeBranchId: homeBranchId,
      fullName: fullName.trim(),
      email: email?.trim().isEmpty ?? true ? null : email!.trim(),
      phone: phone?.trim().isEmpty ?? true ? null : phone!.trim(),
      emergencyContactName: emergencyContactName?.trim().isEmpty ?? true
          ? null
          : emergencyContactName!.trim(),
      emergencyContactPhone: emergencyContactPhone?.trim().isEmpty ?? true
          ? null
          : emergencyContactPhone!.trim(),
    );
    members[memberId] = updated;
    _recordAudit(
      orgId,
      homeBranchId,
      user.id,
      'member.updated',
      'member',
      memberId,
    );
    return updated;
  }

  void updateMyMemberContact({
    required String orgId,
    String? phone,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    final user = requireCurrentUser();
    final existing = members.values
        .where((m) => m.organizationId == orgId && m.userId == user.id)
        .firstOrNull;
    if (existing == null) {
      throw const AppException(
        AppFailure.notFound(message: 'Linked member profile not found.'),
      );
    }
    members[existing.id] = existing.copyWith(
      phone: phone?.trim().isEmpty ?? true ? null : phone!.trim(),
      emergencyContactName: emergencyContactName?.trim().isEmpty ?? true
          ? null
          : emergencyContactName!.trim(),
      emergencyContactPhone: emergencyContactPhone?.trim().isEmpty ?? true
          ? null
          : emergencyContactPhone!.trim(),
    );
  }

  List<StaffAssignmentModel> fetchOrganizationStaff({
    required String orgId,
    String? branchId,
  }) {
    _requirePermission(orgId, 'role.assign', branchId: branchId);
    final now = DateTime.now().toUtc();
    final list = <StaffAssignmentModel>[];
    for (final entry in workspacesByUser.entries) {
      final userId = entry.key;
      final profile = profiles[userId];
      for (final ws in entry.value) {
        if (ws.organizationId != orgId || ws.roleCode == 'member') continue;
        if (branchId != null && ws.branchId != branchId) continue;
        list.add(
          StaffAssignmentModel(
            assignmentId: '$userId|${ws.contextKey}',
            userId: userId,
            fullName: profile?.fullName ?? '',
            email: _emailForUser(userId),
            roleCode: ws.roleCode,
            roleDisplayName: ws.roleDisplayName,
            roleRank: ws.roleRank,
            branchId: ws.branchId,
            branchName: ws.branchName,
            createdAt: now,
          ),
        );
      }
    }
    return list..sort((a, b) => b.roleRank.compareTo(a.roleRank));
  }

  void assignUserRole({
    required String orgId,
    required String targetUserId,
    required String roleCode,
    String? branchId,
  }) {
    final actor = requireCurrentUser();
    _requirePermission(orgId, 'role.assign', branchId: branchId);
    final role = RitmaRole.fromCode(roleCode);
    if (_highestRankForUser(actor.id, orgId) < role.rank) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Cannot assign a role higher than your own rank.',
        ),
      );
    }
    final org = organizations[orgId];
    final branch = branchId != null ? branches[branchId] : null;
    final list = workspacesByUser[targetUserId] ?? <WorkspaceContext>[];
    final candidate = _buildWorkspace(
      orgId: orgId,
      orgName: org?.name ?? 'Organization',
      branchId: branchId,
      branchName: branch?.name,
      role: role,
    );
    if (!list.any((w) => w.contextKey == candidate.contextKey)) {
      list.add(candidate);
      workspacesByUser[targetUserId] = list;
    }
    _recordAudit(
      orgId,
      branchId,
      actor.id,
      'role.assigned',
      'user_role',
      targetUserId,
    );
  }

  void revokeUserRole({required String orgId, required String assignmentId}) {
    final actor = requireCurrentUser();
    final sep = assignmentId.indexOf('|');
    if (sep <= 0) {
      throw const AppException(
        AppFailure.notFound(message: 'Role assignment not found.'),
      );
    }
    final targetUid = assignmentId.substring(0, sep);
    final ctxKey = assignmentId.substring(sep + 1);
    final list = workspacesByUser[targetUid];
    final targetWs = list?.where((w) => w.contextKey == ctxKey).firstOrNull;
    if (list == null || targetWs == null || targetWs.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Role assignment not found.'),
      );
    }
    _requirePermission(orgId, 'role.assign', branchId: targetWs.branchId);
    if (_highestRankForUser(actor.id, orgId) < targetWs.roleRank) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Cannot revoke a role higher than your own rank.',
        ),
      );
    }
    if (targetWs.roleCode == 'org_owner') {
      final ownerCount = workspacesByUser.values
          .expand((w) => w)
          .where((w) => w.organizationId == orgId && w.roleCode == 'org_owner')
          .length;
      if (ownerCount <= 1) {
        throw const AppException(
          AppFailure.conflict(
            message: 'Organization must retain at least one owner.',
            code: 'LAST_ORG_OWNER',
          ),
        );
      }
    }
    list.removeWhere((w) => w.contextKey == ctxKey);
    _recordAudit(
      orgId,
      targetWs.branchId,
      actor.id,
      'role.revoked',
      'user_role',
      targetUid,
    );
  }

  List<OrganizationInvitationModel> fetchOrganizationInvitations({
    required String orgId,
    String? branchId,
  }) {
    _requirePermission(orgId, 'role.assign', branchId: branchId);
    return _staffInviteRecords
        .where(
          (r) =>
              r.organizationId == orgId &&
              r.status == 'pending' &&
              (branchId == null || r.branchId == branchId),
        )
        .map(
          (r) => OrganizationInvitationModel(
            id: r.invitationId,
            invitedEmail: r.invitedEmail,
            roleCode: r.role.code,
            roleDisplayName: r.role.displayName,
            roleRank: r.role.rank,
            branchId: r.branchId,
            branchName: r.branchId != null ? branches[r.branchId]?.name : null,
            status: r.status,
            expiresAt: r.expiresAt,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  void revokeOrganizationInvitation({
    required String orgId,
    required String invitationId,
  }) {
    final actor = requireCurrentUser();
    final idx = _staffInviteRecords.indexWhere(
      (r) => r.organizationId == orgId && r.invitationId == invitationId,
    );
    if (idx < 0) {
      throw const AppException(
        AppFailure.notFound(message: 'Pending invitation not found.'),
      );
    }
    final rec = _staffInviteRecords[idx];
    _requirePermission(orgId, 'role.assign', branchId: rec.branchId);
    if (_highestRankForUser(actor.id, orgId) < rec.role.rank) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Cannot revoke an invitation higher than your own rank.',
        ),
      );
    }
    _staffInviteRecords[idx] = rec.copyWith(status: 'revoked');
    _staffInvites.remove(rec.token);
  }

  List<AuditLogModel> fetchAuditLogs({
    required String orgId,
    String? branchId,
    int limit = 50,
  }) {
    _requirePermission(orgId, 'audit.read', branchId: branchId);
    return auditLogs
        .where(
          (l) =>
              l.organizationId == orgId &&
              (branchId == null || l.branchId == branchId),
        )
        .take(limit)
        .toList();
  }

  ReportExportPayload getReportExportData({
    required String orgId,
    required ReportExportType reportType,
    String? branchId,
    int windowDays = 30,
  }) {
    requireCurrentUser();
    final org = organizations[orgId];
    if (org == null) {
      throw const AppException(
        AppFailure.notFound(message: 'Organization not found.'),
      );
    }
    final allowed = switch (reportType) {
      ReportExportType.visits => _hasOrgPermission(
        orgId,
        'checkin.read',
        branchId: branchId,
      ),
      ReportExportType.payments => _hasOrgPermission(
        orgId,
        'payment.read',
        branchId: branchId,
      ),
      ReportExportType.members => _hasOrgPermission(
        orgId,
        'member.read',
        branchId: branchId,
      ),
      ReportExportType.attendance =>
        _hasOrgPermission(orgId, 'booking.read', branchId: branchId) ||
            _hasOrgPermission(orgId, 'schedule.manage', branchId: branchId) ||
            _hasOrgPermission(orgId, 'attendance.mark', branchId: branchId),
    };
    if (!allowed) {
      throw const AppException(
        AppFailure.forbidden(
          message: 'Not authorized to export this report or branch scope.',
        ),
      );
    }

    final cutoff = DateTime.now().toUtc().subtract(Duration(days: windowDays));
    final scopeName = branchId == null
        ? 'All Branches'
        : (branches[branchId]?.name ?? 'Branch');

    final columns = switch (reportType) {
      ReportExportType.visits => const [
        'Checked In At',
        'Branch',
        'Member Code',
        'Member Name',
        'Method',
        'Checked Out At',
        'Override Reason',
      ],
      ReportExportType.payments => const [
        'Paid At',
        'Branch',
        'Member Code',
        'Member Name',
        'Method',
        'Status',
        'Gross Amount Minor',
        'Refunded Amount Minor',
        'Net Amount Minor',
        'Currency',
        'Reference',
      ],
      ReportExportType.members => const [
        'Member Code',
        'Full Name',
        'Home Branch',
        'Status',
        'Email',
        'Account Claimed',
      ],
      ReportExportType.attendance => const [
        'Starts At',
        'Branch',
        'Session Title',
        'Instructor',
        'Member Code',
        'Member Name',
        'Booking Status',
        'Attendance Status',
      ],
    };

    final rows = switch (reportType) {
      ReportExportType.visits =>
        facilityVisits
            .where(
              (v) =>
                  v.organizationId == orgId &&
                  (branchId == null || v.branchId == branchId) &&
                  !v.checkedInAt.isBefore(cutoff),
            )
            .map((v) {
              final m = members[v.memberId];
              return <dynamic>[
                v.checkedInAt.toIso8601String(),
                branches[v.branchId]?.name ?? '',
                m?.memberCode ?? '',
                m?.fullName ?? v.memberName ?? '',
                v.checkInMethod,
                v.checkedOutAt?.toIso8601String() ?? '',
                v.overrideReason ?? '',
              ];
            })
            .toList(),
      ReportExportType.payments =>
        paymentRecords
            .where(
              (p) =>
                  p.organizationId == orgId &&
                  (branchId == null || p.branchId == branchId) &&
                  !p.paidAt.isBefore(cutoff),
            )
            .map((p) {
              final m = members[p.memberId];
              return <dynamic>[
                p.paidAt.toIso8601String(),
                branches[p.branchId]?.name ?? '',
                m?.memberCode ?? '',
                m?.fullName ?? p.memberDisplayName,
                p.method.label,
                p.status.name,
                p.amountMinor,
                p.refundedAmountMinor,
                p.netAmountMinor,
                p.currencyCode,
                p.externalReference ?? '',
              ];
            })
            .toList(),
      ReportExportType.members =>
        members.values
            .where(
              (m) =>
                  m.organizationId == orgId &&
                  (branchId == null || m.homeBranchId == branchId),
            )
            .map(
              (m) => <dynamic>[
                m.memberCode,
                m.fullName,
                branches[m.homeBranchId]?.name ?? '',
                m.status.name,
                m.email ?? '',
                m.userId != null ? 'Yes' : 'No',
              ],
            )
            .toList(),
      ReportExportType.attendance =>
        classBookings
            .where(
              (b) =>
                  b.organizationId == orgId &&
                  (branchId == null || b.branchId == branchId),
            )
            .map((b) {
              final s = classSessions[b.sessionId];
              final m = members[b.memberId];
              return <dynamic>[
                s?.startsAt.toIso8601String() ?? '',
                branches[b.branchId]?.name ?? '',
                s?.title ?? '',
                s?.instructorDisplayName ?? '',
                m?.memberCode ?? '',
                m?.fullName ?? '',
                b.status.name,
                b.attendanceStatus.name,
              ];
            })
            .toList(),
    };

    return ReportExportPayload(
      reportType: reportType.code,
      organizationName: org.name,
      branchScope: scopeName,
      currencyCode: org.currencyCode,
      timezone: org.timezone,
      generatedAt: DateTime.now().toUtc(),
      columns: columns,
      rows: rows,
    );
  }

  EquipmentAssetModel createEquipmentAsset({
    required String orgId,
    required String branchId,
    required String assetCode,
    required String name,
    required String category,
  }) {
    requireCurrentUser();
    final code = assetCode.trim().toUpperCase();
    if (code.isEmpty || name.trim().isEmpty || category.trim().isEmpty) {
      throw const AppException(
        AppFailure.validation(
          message: 'Asset code, name, and category are required.',
        ),
      );
    }
    final duplicate = equipmentAssets.values.any(
      (a) => a.organizationId == orgId && a.assetCode.toUpperCase() == code,
    );
    if (duplicate) {
      throw const AppException(
        AppFailure.conflict(message: 'Equipment asset code already exists.'),
      );
    }
    final asset = EquipmentAssetModel(
      id: _uuid.v4(),
      organizationId: orgId,
      branchId: branchId,
      assetCode: code,
      name: name.trim(),
      category: category.trim(),
    );
    equipmentAssets[asset.id] = asset;
    return asset;
  }

  EquipmentAssetModel updateEquipmentStatus({
    required String orgId,
    required String assetId,
    required EquipmentStatus status,
  }) {
    requireCurrentUser();
    final existing = equipmentAssets[assetId];
    if (existing == null || existing.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Equipment asset not found.'),
      );
    }
    final updated = existing.copyWith(
      status: status,
      lastServicedAt: status == EquipmentStatus.operational
          ? DateTime.now().toUtc()
          : existing.lastServicedAt,
    );
    equipmentAssets[assetId] = updated;
    return updated;
  }

  MaintenanceTicketModel createMaintenanceTicket({
    required String orgId,
    required String branchId,
    required String assetId,
    required String summary,
    TicketPriority priority = TicketPriority.normal,
  }) {
    requireCurrentUser();
    if (summary.trim().isEmpty) {
      throw const AppException(
        AppFailure.validation(message: 'Issue summary is required.'),
      );
    }
    final asset = equipmentAssets[assetId];
    if (asset == null || asset.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Equipment asset not found.'),
      );
    }
    final ticket = MaintenanceTicketModel(
      id: _uuid.v4(),
      organizationId: orgId,
      branchId: branchId,
      assetId: assetId,
      summary: summary.trim(),
      priority: priority,
      status: TicketStatus.open,
      createdAt: DateTime.now().toUtc(),
    );
    maintenanceTickets[ticket.id] = ticket;
    return ticket;
  }

  MaintenanceTicketModel updateTicketStatus({
    required String orgId,
    required String ticketId,
    required TicketStatus status,
  }) {
    requireCurrentUser();
    final existing = maintenanceTickets[ticketId];
    if (existing == null || existing.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Maintenance ticket not found.'),
      );
    }
    final resolvedAt =
        (status == TicketStatus.resolved || status == TicketStatus.closed)
        ? (existing.resolvedAt ?? DateTime.now().toUtc())
        : null;
    final updated = existing.copyWith(status: status, resolvedAt: resolvedAt);
    maintenanceTickets[ticketId] = updated;
    return updated;
  }

  void markNotificationRead({required String notificationId}) {
    final user = requireCurrentUser();
    final idx = userNotifications.indexWhere(
      (n) => n.id == notificationId && n.userId == user.id,
    );
    if (idx < 0) {
      throw const AppException(
        AppFailure.notFound(message: 'Notification not found.'),
      );
    }
    final existing = userNotifications[idx];
    if (existing.readAt == null) {
      userNotifications[idx] = existing.copyWith(
        readAt: DateTime.now().toUtc(),
      );
    }
  }

  void dispose() {
    authStreamController.close().ignore();
  }
}

class _PendingStaffInvite {
  const _PendingStaffInvite({
    required this.invitationId,
    required this.token,
    required this.invitedEmail,
    required this.organizationId,
    required this.role,
    required this.createdAt,
    required this.expiresAt,
    this.branchId,
    this.status = 'pending',
  });

  final String invitationId;
  final String token;
  final String invitedEmail;
  final String organizationId;
  final String? branchId;
  final RitmaRole role;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String status;

  _PendingStaffInvite copyWith({String? status}) => _PendingStaffInvite(
    invitationId: invitationId,
    token: token,
    invitedEmail: invitedEmail,
    organizationId: organizationId,
    role: role,
    createdAt: createdAt,
    expiresAt: expiresAt,
    branchId: branchId,
    status: status ?? this.status,
  );
}

class _PendingMemberClaim {
  const _PendingMemberClaim({
    required this.organizationId,
    required this.memberId,
  });

  final String organizationId;
  final String memberId;
}

class _AdjustmentRecord {
  const _AdjustmentRecord({
    required this.memberId,
    required this.creditType,
    required this.delta,
  });

  final String memberId;
  final CreditType creditType;
  final int delta;
}

class _CheckInReplay {
  const _CheckInReplay({required this.fingerprint, required this.outcome});

  final String fingerprint;
  final CheckInOutcome outcome;
}

/// Provides the shared in-memory [DemoSandboxEngine] in Demo Sandbox mode.
final demoSandboxEngineProvider = Provider<DemoSandboxEngine>((ref) {
  final engine = DemoSandboxEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

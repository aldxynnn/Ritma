import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../features/auth/domain/auth_user.dart';
import '../../features/auth/domain/ritma_role.dart';
import '../../features/auth/domain/user_profile.dart';
import '../../features/auth/domain/workspace_context.dart';
import '../../features/members/domain/member_model.dart';
import '../../features/organizations/domain/branch_model.dart';
import '../../features/organizations/domain/organization_invitation_result.dart';
import '../../features/organizations/domain/organization_model.dart';
import '../../features/organizations/domain/room_model.dart';
import '../../features/packages/domain/package_models.dart';
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

    _staffInvites['DEMO-STAFF-INVITE'] = const _PendingStaffInvite(
      organizationId: seedOrgId,
      branchId: seedBranchDowntownId,
      role: RitmaRole.branchManager,
    );
    _memberClaims['DEMO-MEMBER-CLAIM'] = const _PendingMemberClaim(
      organizationId: seedOrgId,
      memberId: member2Id,
    );
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
    requireCurrentUser();
    final role = RitmaRole.fromCode(roleCode);
    final token = 'INV-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final invId = _uuid.v4();
    _staffInvites[token] = _PendingStaffInvite(
      organizationId: orgId,
      branchId: branchId,
      role: role,
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
    if (invite == null) {
      throw const AppException(
        AppFailure.validation(
          message:
              'Invalid or expired invitation token (try DEMO-STAFF-INVITE).',
        ),
      );
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
    if (pkg == null || pkg.organizationId != orgId) {
      throw const AppException(
        AppFailure.notFound(message: 'Package not found.'),
      );
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

  void dispose() {
    authStreamController.close().ignore();
  }
}

class _PendingStaffInvite {
  const _PendingStaffInvite({
    required this.organizationId,
    required this.role,
    this.branchId,
  });

  final String organizationId;
  final String? branchId;
  final RitmaRole role;
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

/// Provides the shared in-memory [DemoSandboxEngine] in Demo Sandbox mode.
final demoSandboxEngineProvider = Provider<DemoSandboxEngine>((ref) {
  final engine = DemoSandboxEngine();
  ref.onDispose(engine.dispose);
  return engine;
});

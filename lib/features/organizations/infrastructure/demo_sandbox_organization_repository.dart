import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/audit_log_model.dart';
import '../domain/branch_model.dart';
import '../domain/organization_invitation_result.dart';
import '../domain/organization_model.dart';
import '../domain/organization_repository.dart';
import '../domain/room_model.dart';
import '../domain/staff_management_models.dart';

class DemoSandboxOrganizationRepository extends BaseRepository
    implements OrganizationRepository {
  DemoSandboxOrganizationRepository(this._engine)
    : super(loggerName: 'demo_org_repo');

  final DemoSandboxEngine _engine;

  @override
  Future<Result<String>> createOrganizationWithOwner({
    required String name,
    required String slug,
    required String businessType,
    required String timezone,
    required String currencyCode,
    required String firstBranchName,
    required String firstBranchCode,
  }) {
    return guard(
      () async => _engine.createOrganizationWithOwner(
        name: name,
        slug: slug,
        businessType: businessType,
        timezone: timezone,
        currencyCode: currencyCode,
        firstBranchName: firstBranchName,
        firstBranchCode: firstBranchCode,
      ),
      operation: 'demo.createOrganizationWithOwner',
    );
  }

  @override
  Future<Result<List<BranchModel>>> fetchBranches(String orgId) {
    return guard(() async {
      final list =
          _engine.branches.values
              .where((b) => b.organizationId == orgId)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      return list;
    }, operation: 'demo.fetchBranches');
  }

  @override
  Future<Result<BranchModel>> createBranch({
    required String orgId,
    required String name,
    required String code,
    String? address,
    String? timezone,
  }) {
    return guard(
      () async => _engine.createBranch(
        orgId: orgId,
        name: name,
        code: code,
        address: address,
        timezone: timezone,
      ),
      operation: 'demo.createBranch',
    );
  }

  @override
  Future<Result<List<RoomModel>>> fetchRooms(String orgId, {String? branchId}) {
    return guard(() async {
      final list =
          _engine.rooms.values
              .where(
                (r) =>
                    r.organizationId == orgId &&
                    (branchId == null || r.branchId == branchId),
              )
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      return list;
    }, operation: 'demo.fetchRooms');
  }

  @override
  Future<Result<RoomModel>> createRoom({
    required String orgId,
    required String branchId,
    required String name,
    required String roomType,
    required int defaultCapacity,
  }) {
    return guard(
      () async => _engine.createRoom(
        orgId: orgId,
        branchId: branchId,
        name: name,
        roomType: roomType,
        defaultCapacity: defaultCapacity,
      ),
      operation: 'demo.createRoom',
    );
  }

  @override
  Future<Result<OrganizationInvitationResult>> inviteStaff({
    required String orgId,
    required String email,
    required String roleCode,
    String? branchId,
  }) {
    return guard(
      () async => _engine.inviteStaff(
        orgId: orgId,
        email: email,
        roleCode: roleCode,
        branchId: branchId,
      ),
      operation: 'demo.inviteStaff',
    );
  }

  @override
  Future<Result<OrganizationModel>> fetchOrganization(String orgId) {
    return guard(() async {
      final org = _engine.organizations[orgId];
      if (org == null) {
        throw const AppException(
          AppFailure.notFound(message: 'Organization not found.'),
        );
      }
      return org;
    }, operation: 'demo.fetchOrganization');
  }

  @override
  Future<Result<void>> updateOrganizationSettings({
    required String orgId,
    required String name,
    required String businessType,
    required String timezone,
    required String currencyCode,
  }) {
    return guard(
      () async => _engine.updateOrganizationSettings(
        orgId: orgId,
        name: name,
        businessType: businessType,
        timezone: timezone,
        currencyCode: currencyCode,
      ),
      operation: 'demo.updateOrganizationSettings',
    );
  }

  @override
  Future<Result<void>> rotateOrgSigningKey(String orgId) {
    return guard(
      () async => _engine.rotateOrgSigningKey(orgId),
      operation: 'demo.rotateOrgSigningKey',
    );
  }

  @override
  Future<Result<BranchModel>> updateBranch({
    required String orgId,
    required String branchId,
    required String name,
    required String code,
    String? address,
    String? timezone,
    required bool isActive,
  }) {
    return guard(
      () async => _engine.updateBranch(
        orgId: orgId,
        branchId: branchId,
        name: name,
        code: code,
        address: address,
        timezone: timezone,
        isActive: isActive,
      ),
      operation: 'demo.updateBranch',
    );
  }

  @override
  Future<Result<RoomModel>> updateRoom({
    required String orgId,
    required String roomId,
    required String name,
    required String roomType,
    required int defaultCapacity,
    required bool isActive,
  }) {
    return guard(
      () async => _engine.updateRoom(
        orgId: orgId,
        roomId: roomId,
        name: name,
        roomType: roomType,
        defaultCapacity: defaultCapacity,
        isActive: isActive,
      ),
      operation: 'demo.updateRoom',
    );
  }

  @override
  Future<Result<List<StaffAssignmentModel>>> fetchOrganizationStaff({
    required String orgId,
    String? branchId,
  }) {
    return guard(
      () async =>
          _engine.fetchOrganizationStaff(orgId: orgId, branchId: branchId),
      operation: 'demo.fetchOrganizationStaff',
    );
  }

  @override
  Future<Result<void>> assignUserRole({
    required String orgId,
    required String targetUserId,
    required String roleCode,
    String? branchId,
  }) {
    return guard(
      () async => _engine.assignUserRole(
        orgId: orgId,
        targetUserId: targetUserId,
        roleCode: roleCode,
        branchId: branchId,
      ),
      operation: 'demo.assignUserRole',
    );
  }

  @override
  Future<Result<void>> revokeUserRole({
    required String orgId,
    required String assignmentId,
  }) {
    return guard(
      () async =>
          _engine.revokeUserRole(orgId: orgId, assignmentId: assignmentId),
      operation: 'demo.revokeUserRole',
    );
  }

  @override
  Future<Result<List<OrganizationInvitationModel>>>
  fetchOrganizationInvitations({required String orgId, String? branchId}) {
    return guard(
      () async => _engine.fetchOrganizationInvitations(
        orgId: orgId,
        branchId: branchId,
      ),
      operation: 'demo.fetchOrganizationInvitations',
    );
  }

  @override
  Future<Result<void>> revokeOrganizationInvitation({
    required String orgId,
    required String invitationId,
  }) {
    return guard(
      () async => _engine.revokeOrganizationInvitation(
        orgId: orgId,
        invitationId: invitationId,
      ),
      operation: 'demo.revokeOrganizationInvitation',
    );
  }

  @override
  Future<Result<List<AuditLogModel>>> fetchAuditLogs({
    required String orgId,
    String? branchId,
    int limit = 50,
  }) {
    return guard(
      () async => _engine.fetchAuditLogs(
        orgId: orgId,
        branchId: branchId,
        limit: limit,
      ),
      operation: 'demo.fetchAuditLogs',
    );
  }
}

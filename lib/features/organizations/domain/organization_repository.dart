import '../../../core/result/result.dart';
import 'audit_log_model.dart';
import 'branch_model.dart';
import 'organization_invitation_result.dart';
import 'organization_model.dart';
import 'room_model.dart';
import 'staff_management_models.dart';

abstract interface class OrganizationRepository {
  Future<Result<String>> createOrganizationWithOwner({
    required String name,
    required String slug,
    required String businessType,
    required String timezone,
    required String currencyCode,
    required String firstBranchName,
    required String firstBranchCode,
  });

  Future<Result<OrganizationModel>> fetchOrganization(String orgId);

  Future<Result<void>> updateOrganizationSettings({
    required String orgId,
    required String name,
    required String businessType,
    required String timezone,
    required String currencyCode,
  });

  Future<Result<void>> rotateOrgSigningKey(String orgId);

  Future<Result<List<BranchModel>>> fetchBranches(String orgId);

  Future<Result<BranchModel>> createBranch({
    required String orgId,
    required String name,
    required String code,
    String? address,
    String? timezone,
  });

  Future<Result<BranchModel>> updateBranch({
    required String orgId,
    required String branchId,
    required String name,
    required String code,
    String? address,
    String? timezone,
    required bool isActive,
  });

  Future<Result<List<RoomModel>>> fetchRooms(String orgId, {String? branchId});

  Future<Result<RoomModel>> createRoom({
    required String orgId,
    required String branchId,
    required String name,
    required String roomType,
    required int defaultCapacity,
  });

  Future<Result<RoomModel>> updateRoom({
    required String orgId,
    required String roomId,
    required String name,
    required String roomType,
    required int defaultCapacity,
    required bool isActive,
  });

  Future<Result<OrganizationInvitationResult>> inviteStaff({
    required String orgId,
    required String email,
    required String roleCode,
    String? branchId,
  });

  Future<Result<List<StaffAssignmentModel>>> fetchOrganizationStaff({
    required String orgId,
    String? branchId,
  });

  Future<Result<void>> assignUserRole({
    required String orgId,
    required String targetUserId,
    required String roleCode,
    String? branchId,
  });

  Future<Result<void>> revokeUserRole({
    required String orgId,
    required String assignmentId,
  });

  Future<Result<List<OrganizationInvitationModel>>>
  fetchOrganizationInvitations({required String orgId, String? branchId});

  Future<Result<void>> revokeOrganizationInvitation({
    required String orgId,
    required String invitationId,
  });

  Future<Result<List<AuditLogModel>>> fetchAuditLogs({
    required String orgId,
    String? branchId,
    int limit = 50,
  });
}

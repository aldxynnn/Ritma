import '../../../core/result/result.dart';
import 'branch_model.dart';
import 'organization_invitation_result.dart';
import 'room_model.dart';

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

  Future<Result<List<BranchModel>>> fetchBranches(String orgId);

  Future<Result<BranchModel>> createBranch({
    required String orgId,
    required String name,
    required String code,
    String? address,
    String? timezone,
  });

  Future<Result<List<RoomModel>>> fetchRooms(String orgId, {String? branchId});

  Future<Result<RoomModel>> createRoom({
    required String orgId,
    required String branchId,
    required String name,
    required String roomType,
    required int defaultCapacity,
  });

  Future<Result<OrganizationInvitationResult>> inviteStaff({
    required String orgId,
    required String email,
    required String roleCode,
    String? branchId,
  });
}

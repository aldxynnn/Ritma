import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/branch_model.dart';
import '../domain/organization_invitation_result.dart';
import '../domain/organization_repository.dart';
import '../domain/room_model.dart';

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
}

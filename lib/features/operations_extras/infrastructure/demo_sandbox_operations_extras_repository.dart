import '../../../core/demo/demo_sandbox_engine.dart';
import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/operations_extras_models.dart';
import '../domain/operations_extras_repository.dart';

class DemoSandboxOperationsExtrasRepository extends BaseRepository
    implements OperationsExtrasRepository {
  DemoSandboxOperationsExtrasRepository(this._engine)
    : super(loggerName: 'demo_ops_extras_repo');

  final DemoSandboxEngine _engine;

  @override
  Future<Result<List<EquipmentAssetModel>>> fetchEquipmentAssets({
    required String orgId,
    String? branchId,
  }) {
    return guard(() async {
      final list =
          _engine.equipmentAssets.values
              .where(
                (a) =>
                    a.organizationId == orgId &&
                    (branchId == null || a.branchId == branchId),
              )
              .toList()
            ..sort((a, b) => a.assetCode.compareTo(b.assetCode));
      return list;
    }, operation: 'demo.fetchEquipmentAssets');
  }

  @override
  Future<Result<EquipmentAssetModel>> createEquipmentAsset({
    required String orgId,
    required String branchId,
    required String assetCode,
    required String name,
    required String category,
  }) {
    return guard(
      () async => _engine.createEquipmentAsset(
        orgId: orgId,
        branchId: branchId,
        assetCode: assetCode,
        name: name,
        category: category,
      ),
      operation: 'demo.createEquipmentAsset',
    );
  }

  @override
  Future<Result<EquipmentAssetModel>> updateEquipmentStatus({
    required String orgId,
    required String assetId,
    required EquipmentStatus status,
  }) {
    return guard(
      () async => _engine.updateEquipmentStatus(
        orgId: orgId,
        assetId: assetId,
        status: status,
      ),
      operation: 'demo.updateEquipmentStatus',
    );
  }

  @override
  Future<Result<List<MaintenanceTicketModel>>> fetchMaintenanceTickets({
    required String orgId,
    String? branchId,
  }) {
    return guard(() async {
      final list =
          _engine.maintenanceTickets.values
              .where(
                (t) =>
                    t.organizationId == orgId &&
                    (branchId == null || t.branchId == branchId),
              )
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }, operation: 'demo.fetchMaintenanceTickets');
  }

  @override
  Future<Result<MaintenanceTicketModel>> createMaintenanceTicket({
    required String orgId,
    required String branchId,
    required String assetId,
    required String summary,
    TicketPriority priority = TicketPriority.normal,
  }) {
    return guard(
      () async => _engine.createMaintenanceTicket(
        orgId: orgId,
        branchId: branchId,
        assetId: assetId,
        summary: summary,
        priority: priority,
      ),
      operation: 'demo.createMaintenanceTicket',
    );
  }

  @override
  Future<Result<MaintenanceTicketModel>> updateTicketStatus({
    required String orgId,
    required String ticketId,
    required TicketStatus status,
  }) {
    return guard(
      () async => _engine.updateTicketStatus(
        orgId: orgId,
        ticketId: ticketId,
        status: status,
      ),
      operation: 'demo.updateTicketStatus',
    );
  }

  @override
  Future<Result<List<UserNotificationModel>>> fetchNotifications({
    String? orgId,
  }) {
    return guard(() async {
      final user = _engine.requireCurrentUser();
      final list =
          _engine.userNotifications
              .where(
                (n) =>
                    n.userId == user.id &&
                    (orgId == null || n.organizationId == orgId),
              )
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }, operation: 'demo.fetchNotifications');
  }

  @override
  Future<Result<void>> markNotificationRead({required String notificationId}) {
    return guard(
      () async => _engine.markNotificationRead(notificationId: notificationId),
      operation: 'demo.markNotificationRead',
    );
  }
}

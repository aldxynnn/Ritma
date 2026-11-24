import '../../../core/result/result.dart';
import 'operations_extras_models.dart';

abstract interface class OperationsExtrasRepository {
  Future<Result<List<EquipmentAssetModel>>> fetchEquipmentAssets({
    required String orgId,
    String? branchId,
  });

  Future<Result<EquipmentAssetModel>> createEquipmentAsset({
    required String orgId,
    required String branchId,
    required String assetCode,
    required String name,
    required String category,
  });

  Future<Result<EquipmentAssetModel>> updateEquipmentStatus({
    required String orgId,
    required String assetId,
    required EquipmentStatus status,
  });

  Future<Result<List<MaintenanceTicketModel>>> fetchMaintenanceTickets({
    required String orgId,
    String? branchId,
  });

  Future<Result<MaintenanceTicketModel>> createMaintenanceTicket({
    required String orgId,
    required String branchId,
    required String assetId,
    required String summary,
    TicketPriority priority = TicketPriority.normal,
  });

  Future<Result<MaintenanceTicketModel>> updateTicketStatus({
    required String orgId,
    required String ticketId,
    required TicketStatus status,
  });

  Future<Result<List<UserNotificationModel>>> fetchNotifications({
    String? orgId,
  });

  Future<Result<void>> markNotificationRead({required String notificationId});
}

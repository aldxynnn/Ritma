import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/repository/base_repository.dart';
import '../../../core/result/result.dart';
import '../domain/operations_extras_models.dart';
import '../domain/operations_extras_repository.dart';

class SupabaseOperationsExtrasRepository extends BaseRepository
    implements OperationsExtrasRepository {
  SupabaseOperationsExtrasRepository(this._client)
    : super(loggerName: 'supabase_ops_extras_repo');

  final sb.SupabaseClient _client;

  static const String _assetColumns =
      'id, organization_id, branch_id, asset_code, name, category, status, last_serviced_at';
  static const String _ticketColumns =
      'id, organization_id, branch_id, asset_id, summary, priority, status, resolved_at, created_at';
  static const String _notificationColumns =
      'id, organization_id, user_id, title, body, category, read_at, created_at';

  String _equipmentStatusWire(EquipmentStatus s) => switch (s) {
    EquipmentStatus.operational => 'operational',
    EquipmentStatus.needsService => 'needs_service',
    EquipmentStatus.outOfOrder => 'out_of_order',
    EquipmentStatus.retired => 'retired',
  };

  String _ticketStatusWire(TicketStatus s) => switch (s) {
    TicketStatus.open => 'open',
    TicketStatus.inProgress => 'in_progress',
    TicketStatus.resolved => 'resolved',
    TicketStatus.closed => 'closed',
  };

  @override
  Future<Result<List<EquipmentAssetModel>>> fetchEquipmentAssets({
    required String orgId,
    String? branchId,
  }) {
    return guard(() async {
      var builder = _client
          .from('equipment_assets')
          .select(_assetColumns)
          .eq('organization_id', orgId);
      if (branchId != null) {
        builder = builder.eq('branch_id', branchId);
      }
      final rows = await builder.order('asset_code', ascending: true);
      return rows
          .map(
            (r) => EquipmentAssetModel.fromJson(Map<String, dynamic>.from(r)),
          )
          .toList();
    }, operation: 'fetchEquipmentAssets');
  }

  @override
  Future<Result<EquipmentAssetModel>> createEquipmentAsset({
    required String orgId,
    required String branchId,
    required String assetCode,
    required String name,
    required String category,
  }) {
    return guard(() async {
      final row = await _client
          .from('equipment_assets')
          .insert(<String, dynamic>{
            'organization_id': orgId,
            'branch_id': branchId,
            'asset_code': assetCode.trim().toUpperCase(),
            'name': name.trim(),
            'category': category.trim(),
          })
          .select(_assetColumns)
          .single();
      return EquipmentAssetModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'createEquipmentAsset');
  }

  @override
  Future<Result<EquipmentAssetModel>> updateEquipmentStatus({
    required String orgId,
    required String assetId,
    required EquipmentStatus status,
  }) {
    return guard(() async {
      final updatePayload = <String, dynamic>{
        'status': _equipmentStatusWire(status),
        if (status == EquipmentStatus.operational)
          'last_serviced_at': DateTime.now().toUtc().toIso8601String(),
      };
      final row = await _client
          .from('equipment_assets')
          .update(updatePayload)
          .eq('organization_id', orgId)
          .eq('id', assetId)
          .select(_assetColumns)
          .single();
      return EquipmentAssetModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'updateEquipmentStatus');
  }

  @override
  Future<Result<List<MaintenanceTicketModel>>> fetchMaintenanceTickets({
    required String orgId,
    String? branchId,
  }) {
    return guard(() async {
      var builder = _client
          .from('equipment_maintenance_tickets')
          .select(_ticketColumns)
          .eq('organization_id', orgId);
      if (branchId != null) {
        builder = builder.eq('branch_id', branchId);
      }
      final rows = await builder.order('created_at', ascending: false);
      return rows
          .map(
            (r) =>
                MaintenanceTicketModel.fromJson(Map<String, dynamic>.from(r)),
          )
          .toList();
    }, operation: 'fetchMaintenanceTickets');
  }

  @override
  Future<Result<MaintenanceTicketModel>> createMaintenanceTicket({
    required String orgId,
    required String branchId,
    required String assetId,
    required String summary,
    TicketPriority priority = TicketPriority.normal,
  }) {
    return guard(() async {
      final row = await _client
          .from('equipment_maintenance_tickets')
          .insert(<String, dynamic>{
            'organization_id': orgId,
            'branch_id': branchId,
            'asset_id': assetId,
            'reported_by': _client.auth.currentUser?.id,
            'summary': summary.trim(),
            'priority': priority.name,
          })
          .select(_ticketColumns)
          .single();
      return MaintenanceTicketModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'createMaintenanceTicket');
  }

  @override
  Future<Result<MaintenanceTicketModel>> updateTicketStatus({
    required String orgId,
    required String ticketId,
    required TicketStatus status,
  }) {
    return guard(() async {
      final resolvedAt =
          (status == TicketStatus.resolved || status == TicketStatus.closed)
          ? DateTime.now().toUtc().toIso8601String()
          : null;
      final row = await _client
          .from('equipment_maintenance_tickets')
          .update(<String, dynamic>{
            'status': _ticketStatusWire(status),
            'resolved_at': resolvedAt,
          })
          .eq('organization_id', orgId)
          .eq('id', ticketId)
          .select(_ticketColumns)
          .single();
      return MaintenanceTicketModel.fromJson(Map<String, dynamic>.from(row));
    }, operation: 'updateTicketStatus');
  }

  @override
  Future<Result<List<UserNotificationModel>>> fetchNotifications({
    String? orgId,
  }) {
    return guard(() async {
      var builder = _client
          .from('user_notifications')
          .select(_notificationColumns);
      if (orgId != null) {
        builder = builder.eq('organization_id', orgId);
      }
      final rows = await builder
          .order('created_at', ascending: false)
          .limit(30);
      return rows
          .map(
            (r) => UserNotificationModel.fromJson(Map<String, dynamic>.from(r)),
          )
          .toList();
    }, operation: 'fetchNotifications');
  }

  @override
  Future<Result<void>> markNotificationRead({required String notificationId}) {
    return guard(() async {
      await _client
          .from('user_notifications')
          .update(<String, dynamic>{
            'read_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', notificationId);
    }, operation: 'markNotificationRead');
  }
}

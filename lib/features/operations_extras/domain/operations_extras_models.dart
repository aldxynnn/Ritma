import 'package:freezed_annotation/freezed_annotation.dart';

part 'operations_extras_models.freezed.dart';
part 'operations_extras_models.g.dart';

enum EquipmentStatus {
  operational,
  @JsonValue('needs_service')
  needsService,
  @JsonValue('out_of_order')
  outOfOrder,
  retired;

  String get displayLabel => switch (this) {
    EquipmentStatus.operational => 'Operational',
    EquipmentStatus.needsService => 'Needs Service',
    EquipmentStatus.outOfOrder => 'Out of Order',
    EquipmentStatus.retired => 'Retired',
  };
}

enum TicketPriority {
  low,
  normal,
  high,
  critical;

  String get displayLabel => switch (this) {
    TicketPriority.low => 'Low',
    TicketPriority.normal => 'Normal',
    TicketPriority.high => 'High',
    TicketPriority.critical => 'Critical',
  };
}

enum TicketStatus {
  open,
  @JsonValue('in_progress')
  inProgress,
  resolved,
  closed;

  String get displayLabel => switch (this) {
    TicketStatus.open => 'Open',
    TicketStatus.inProgress => 'In Progress',
    TicketStatus.resolved => 'Resolved',
    TicketStatus.closed => 'Closed',
  };
}

@freezed
abstract class EquipmentAssetModel with _$EquipmentAssetModel {
  const factory EquipmentAssetModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'asset_code') required String assetCode,
    required String name,
    required String category,
    @Default(EquipmentStatus.operational) EquipmentStatus status,
    @JsonKey(name: 'last_serviced_at') DateTime? lastServicedAt,
  }) = _EquipmentAssetModel;

  factory EquipmentAssetModel.fromJson(Map<String, dynamic> json) =>
      _$EquipmentAssetModelFromJson(json);
}

@freezed
abstract class MaintenanceTicketModel with _$MaintenanceTicketModel {
  const factory MaintenanceTicketModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'branch_id') required String branchId,
    @JsonKey(name: 'asset_id') required String assetId,
    required String summary,
    @Default(TicketPriority.normal) TicketPriority priority,
    @Default(TicketStatus.open) TicketStatus status,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MaintenanceTicketModel;

  factory MaintenanceTicketModel.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceTicketModelFromJson(json);
}

@freezed
abstract class UserNotificationModel with _$UserNotificationModel {
  const factory UserNotificationModel({
    required String id,
    @JsonKey(name: 'organization_id') required String organizationId,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    required String body,
    required String category,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserNotificationModel;

  factory UserNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationModelFromJson(json);
}

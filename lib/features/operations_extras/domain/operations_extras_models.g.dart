// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'operations_extras_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EquipmentAssetModel _$EquipmentAssetModelFromJson(Map<String, dynamic> json) =>
    _EquipmentAssetModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      branchId: json['branch_id'] as String,
      assetCode: json['asset_code'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      status:
          $enumDecodeNullable(_$EquipmentStatusEnumMap, json['status']) ??
          EquipmentStatus.operational,
      lastServicedAt: json['last_serviced_at'] == null
          ? null
          : DateTime.parse(json['last_serviced_at'] as String),
    );

Map<String, dynamic> _$EquipmentAssetModelToJson(
  _EquipmentAssetModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'branch_id': instance.branchId,
  'asset_code': instance.assetCode,
  'name': instance.name,
  'category': instance.category,
  'status': _$EquipmentStatusEnumMap[instance.status]!,
  'last_serviced_at': instance.lastServicedAt?.toIso8601String(),
};

const _$EquipmentStatusEnumMap = {
  EquipmentStatus.operational: 'operational',
  EquipmentStatus.needsService: 'needs_service',
  EquipmentStatus.outOfOrder: 'out_of_order',
  EquipmentStatus.retired: 'retired',
};

_MaintenanceTicketModel _$MaintenanceTicketModelFromJson(
  Map<String, dynamic> json,
) => _MaintenanceTicketModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  branchId: json['branch_id'] as String,
  assetId: json['asset_id'] as String,
  summary: json['summary'] as String,
  priority:
      $enumDecodeNullable(_$TicketPriorityEnumMap, json['priority']) ??
      TicketPriority.normal,
  status:
      $enumDecodeNullable(_$TicketStatusEnumMap, json['status']) ??
      TicketStatus.open,
  resolvedAt: json['resolved_at'] == null
      ? null
      : DateTime.parse(json['resolved_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$MaintenanceTicketModelToJson(
  _MaintenanceTicketModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'branch_id': instance.branchId,
  'asset_id': instance.assetId,
  'summary': instance.summary,
  'priority': _$TicketPriorityEnumMap[instance.priority]!,
  'status': _$TicketStatusEnumMap[instance.status]!,
  'resolved_at': instance.resolvedAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$TicketPriorityEnumMap = {
  TicketPriority.low: 'low',
  TicketPriority.normal: 'normal',
  TicketPriority.high: 'high',
  TicketPriority.critical: 'critical',
};

const _$TicketStatusEnumMap = {
  TicketStatus.open: 'open',
  TicketStatus.inProgress: 'in_progress',
  TicketStatus.resolved: 'resolved',
  TicketStatus.closed: 'closed',
};

_UserNotificationModel _$UserNotificationModelFromJson(
  Map<String, dynamic> json,
) => _UserNotificationModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  userId: json['user_id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  category: json['category'] as String,
  readAt: json['read_at'] == null
      ? null
      : DateTime.parse(json['read_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserNotificationModelToJson(
  _UserNotificationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'organization_id': instance.organizationId,
  'user_id': instance.userId,
  'title': instance.title,
  'body': instance.body,
  'category': instance.category,
  'read_at': instance.readAt?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

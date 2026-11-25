// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLogModel _$AuditLogModelFromJson(Map<String, dynamic> json) =>
    _AuditLogModel(
      id: json['id'] as String,
      organizationId: json['organization_id'] as String,
      branchId: json['branch_id'] as String?,
      actorUserId: json['actor_user_id'] as String?,
      action: json['action'] as String,
      targetType: json['target_type'] as String? ?? '',
      targetId: json['target_id'] as String?,
      metadata:
          json['metadata'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AuditLogModelToJson(_AuditLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'branch_id': instance.branchId,
      'actor_user_id': instance.actorUserId,
      'action': instance.action,
      'target_type': instance.targetType,
      'target_id': instance.targetId,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
    };

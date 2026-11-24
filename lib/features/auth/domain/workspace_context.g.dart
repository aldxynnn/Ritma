// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkspaceContext _$WorkspaceContextFromJson(Map<String, dynamic> json) =>
    _WorkspaceContext(
      organizationId: json['organization_id'] as String,
      organizationName: json['organization_name'] as String,
      branchId: json['branch_id'] as String?,
      branchName: json['branch_name'] as String?,
      roleCode: json['role_code'] as String,
      roleDisplayName: json['role_display_name'] as String,
      roleRank: (json['role_rank'] as num).toInt(),
      memberId: json['member_id'] as String?,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$WorkspaceContextToJson(_WorkspaceContext instance) =>
    <String, dynamic>{
      'organization_id': instance.organizationId,
      'organization_name': instance.organizationName,
      'branch_id': instance.branchId,
      'branch_name': instance.branchName,
      'role_code': instance.roleCode,
      'role_display_name': instance.roleDisplayName,
      'role_rank': instance.roleRank,
      'member_id': instance.memberId,
      'permissions': instance.permissions,
    };

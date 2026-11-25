// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_management_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StaffAssignmentModel _$StaffAssignmentModelFromJson(
  Map<String, dynamic> json,
) => _StaffAssignmentModel(
  assignmentId: json['assignment_id'] as String,
  userId: json['user_id'] as String,
  fullName: json['full_name'] as String? ?? '',
  email: json['email'] as String? ?? '',
  roleCode: json['role_code'] as String,
  roleDisplayName: json['role_display_name'] as String? ?? '',
  roleRank: (json['role_rank'] as num?)?.toInt() ?? 0,
  branchId: json['branch_id'] as String?,
  branchName: json['branch_name'] as String?,
  status: json['status'] as String? ?? 'active',
  createdAt: DateTime.parse(json['created_at'] as String),
  revokedAt: json['revoked_at'] == null
      ? null
      : DateTime.parse(json['revoked_at'] as String),
);

Map<String, dynamic> _$StaffAssignmentModelToJson(
  _StaffAssignmentModel instance,
) => <String, dynamic>{
  'assignment_id': instance.assignmentId,
  'user_id': instance.userId,
  'full_name': instance.fullName,
  'email': instance.email,
  'role_code': instance.roleCode,
  'role_display_name': instance.roleDisplayName,
  'role_rank': instance.roleRank,
  'branch_id': instance.branchId,
  'branch_name': instance.branchName,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'revoked_at': instance.revokedAt?.toIso8601String(),
};

_OrganizationInvitationModel _$OrganizationInvitationModelFromJson(
  Map<String, dynamic> json,
) => _OrganizationInvitationModel(
  id: json['id'] as String,
  invitedEmail: json['invited_email'] as String,
  roleCode: json['role_code'] as String,
  roleDisplayName: json['role_display_name'] as String? ?? '',
  roleRank: (json['role_rank'] as num?)?.toInt() ?? 0,
  branchId: json['branch_id'] as String?,
  branchName: json['branch_name'] as String?,
  status: json['status'] as String? ?? 'pending',
  expiresAt: DateTime.parse(json['expires_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$OrganizationInvitationModelToJson(
  _OrganizationInvitationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'invited_email': instance.invitedEmail,
  'role_code': instance.roleCode,
  'role_display_name': instance.roleDisplayName,
  'role_rank': instance.roleRank,
  'branch_id': instance.branchId,
  'branch_name': instance.branchName,
  'status': instance.status,
  'expires_at': instance.expiresAt.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
};

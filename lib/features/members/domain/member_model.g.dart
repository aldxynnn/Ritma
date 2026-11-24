// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberModel _$MemberModelFromJson(Map<String, dynamic> json) => _MemberModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  userId: json['user_id'] as String?,
  homeBranchId: json['home_branch_id'] as String,
  memberCode: json['member_code'] as String,
  fullName: json['full_name'] as String,
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  emergencyContactName: json['emergency_contact_name'] as String?,
  emergencyContactPhone: json['emergency_contact_phone'] as String?,
  status:
      $enumDecodeNullable(_$MemberStatusEnumMap, json['status']) ??
      MemberStatus.active,
);

Map<String, dynamic> _$MemberModelToJson(_MemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'user_id': instance.userId,
      'home_branch_id': instance.homeBranchId,
      'member_code': instance.memberCode,
      'full_name': instance.fullName,
      'email': instance.email,
      'phone': instance.phone,
      'emergency_contact_name': instance.emergencyContactName,
      'emergency_contact_phone': instance.emergencyContactPhone,
      'status': _$MemberStatusEnumMap[instance.status]!,
    };

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.frozen: 'frozen',
  MemberStatus.suspended: 'suspended',
  MemberStatus.archived: 'archived',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BranchModel _$BranchModelFromJson(Map<String, dynamic> json) => _BranchModel(
  id: json['id'] as String,
  organizationId: json['organization_id'] as String,
  name: json['name'] as String,
  code: json['code'] as String,
  address: json['address'] as String?,
  timezone: json['timezone'] as String?,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$BranchModelToJson(_BranchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'organization_id': instance.organizationId,
      'name': instance.name,
      'code': instance.code,
      'address': instance.address,
      'timezone': instance.timezone,
      'is_active': instance.isActive,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TenantContext _$TenantContextFromJson(Map<String, dynamic> json) =>
    _TenantContext(
      organizationId: json['organizationId'] as String,
      branchId: json['branchId'] as String?,
    );

Map<String, dynamic> _$TenantContextToJson(_TenantContext instance) =>
    <String, dynamic>{
      'organizationId': instance.organizationId,
      'branchId': instance.branchId,
    };

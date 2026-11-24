// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OrganizationModel _$OrganizationModelFromJson(Map<String, dynamic> json) =>
    _OrganizationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      businessType: json['business_type'] as String? ?? 'hybrid',
      timezone: json['timezone'] as String? ?? 'UTC',
      currencyCode: json['currency_code'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'active',
    );

Map<String, dynamic> _$OrganizationModelToJson(_OrganizationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'business_type': instance.businessType,
      'timezone': instance.timezone,
      'currency_code': instance.currencyCode,
      'status': instance.status,
    };
